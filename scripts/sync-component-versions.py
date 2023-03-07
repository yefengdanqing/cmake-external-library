#!/usr/bin/env python2.7
# -*- encoding: utf-8 -*-
# -*- mode: python -*-

from __future__ import print_function
from __future__ import absolute_import
from __future__ import division

def work_dir(path):
    import os
    import contextlib
    @contextlib.contextmanager
    def current_dir():
        saved = os.getcwd()
        os.chdir(path)
        try:
            yield saved
        finally:
            os.chdir(saved)
    return current_dir()

class ExternalComponentInfo(object):
    def __init__(self):
        self.index = None
        self.name = None
        self.branch = None
        self.tag = None
        self.remote_url = None
        self.work_dir = None

    def __str__(self):
        string = '  %s. %s: ' % (self.index, self.name)
        string += '%s@%s' % (self.branch, self.tag)
        return string

class ExternalComponentInfoDatabase(object):
    def __init__(self):
        self.components = list()

    @property
    def external(self):
        return self.components[0]

    def __str__(self):
        return '\n'.join(str(x) for x in self.components)

class ExternalComponentVersionSynchronizer(object):
    def __get_toplevel_dir(self):
        import os
        path = os.path.abspath(__file__)
        path = os.path.dirname(path)
        path = os.path.dirname(path)
        return path

    def __get_external_branch(self, toplevel_dir):
        import subprocess
        with work_dir(toplevel_dir):
            args = 'git', 'rev-parse', '--abbrev-ref', 'HEAD'
            output = subprocess.check_output(args)
            return output.strip()

    def __get_external_tag(self, toplevel_dir):
        import subprocess
        with work_dir(toplevel_dir):
            args = 'git', 'rev-parse', 'HEAD'
            output = subprocess.check_output(args)
            return output.strip()

    def __get_external_url(self, toplevel_dir):
        import subprocess
        with work_dir(toplevel_dir):
            args = 'git', 'remote', 'get-url', 'origin'
            output = subprocess.check_output(args)
            return output.strip()

    def __parse_components(self, toplevel_dir):
        import os
        comps = []
        for item in os.listdir(toplevel_dir):
            item_path = os.path.join(toplevel_dir, item)
            check_path = os.path.join(item_path, 'check.cmake')
            if os.path.isfile(check_path):
                comps.append(item)
        return tuple(comps)

    def __map_component_dep_url(self, toplevel_dir, component, dep_url):
        if '_' in component:
            component = component.replace('_', '-')
            dep_url = dep_url.replace('${_DEP_LNAME}', component)
        else:
            dep_url = dep_url.replace('${_DEP_NAME}', component)
        return dep_url

    def __get_component_dep_url(self, toplevel_dir, component):
        import os
        import re
        pattern = r'set\(_DEP_URL (.+)\)'
        path = os.path.join(toplevel_dir, component, 'check.cmake')
        with open(path) as fin:
            content = fin.read()
        match = re.search(pattern, content)
        if match is None:
            message = "_DEP_URL not found in %r" % path
            raise RuntimeError(message)
        dep_url = match.group(1)
        dep_url = self.__map_component_dep_url(toplevel_dir, component, dep_url)
        return dep_url

    def __get_component_dep_branch(self, toplevel_dir, component):
        import os
        import re
        pattern = r'set\(_DEP_BRANCH (.+)\)'
        path = os.path.join(toplevel_dir, component, 'check.cmake')
        with open(path) as fin:
            content = fin.read()
        match = re.search(pattern, content)
        if match is None:
            message = "_DEP_BRANCH not found in %r" % path
            raise RuntimeError(message)
        dep_branch = match.group(1)
        return dep_branch

    def __get_component_dep_tag(self, toplevel_dir, component):
        import os
        import re
        pattern = r'set\(_DEP_TAG (\w+)\)'
        path = os.path.join(toplevel_dir, component, 'check.cmake')
        with open(path) as fin:
            content = fin.read()
        match = re.search(pattern, content)
        if match is None:
            message = "_DEP_TAG not found in %r" % path
            raise RuntimeError(message)
        dep_tag = match.group(1)
        return dep_tag

    def __update_component_dep_tag(self, check_cmake_path, new_tag):
        import re
        pattern = r'set\(_DEP_TAG (\w+)\)'
        with open(check_cmake_path) as fin:
            content = fin.read()
        repl = 'set(_DEP_TAG %s)' % new_tag
        new_content = re.sub(pattern, repl, content)
        with open(check_cmake_path, 'w') as fout:
            fout.write(new_content)

    def __get_component_work_dir(self, toplevel_dir, comp):
        import os
        dir_path = os.path.join(toplevel_dir, 'components', comp)
        return dir_path

    def __get_component_dependencies(self, toplevel_dir, component):
        import os
        import re
        pattern = r'message\(FATAL_ERROR "\$\{_DEP_NAME\} requires ([^\s:"]+)"\)'
        path = os.path.join(toplevel_dir, component, 'check.cmake')
        with open(path) as fin:
            content = fin.read()
        deps = []
        saw = set()
        for match in re.finditer(pattern, content):
            dep = match.group(1)
            if dep in saw:
                message = "duplicate dependency %r " % dep
                message += "detected in %r" % path
                raise RuntimeError(message)
            deps.append(dep)
        return tuple(deps)

    def __filter_components(self, toplevel_dir, components, update_mxnet):
        import os
        comps = []
        filter_list=['llvm', 'r3c', 'seastar', "pytorch", "ppconsul"]
        if not update_mxnet:
            filter_list.append('mxnet_sdk')
        for comp in components:
            if comp in filter_list:
                continue
            dep_url = self.__get_component_dep_url(toplevel_dir, comp)
            if 'gitlab.mobvista.com:ml-platform' in dep_url:
                comps.append(comp)
        return tuple(comps)

    def __build_dependency_graph(self, toplevel_dir, components):
        graph = dict()
        for comp in components:
            deps = self.__get_component_dependencies(toplevel_dir, comp)
            for dep in deps:
                if dep in components:
                    if comp not in graph:
                        graph[comp] = list()
                    graph[comp].append(dep)
        return graph

    def __get_updating_order(self, toplevel_dir, graph):
        result = list()
        result.append("ml_unity")
        stack = list()
        for comp in graph:
            stack.append((comp, False))
        mark = dict()
        while stack:
            node, status = stack.pop()
            if status:
                mark[node] = True
                result.append(node)
            else:
                marker = mark.get(node)
                if marker == True:
                    continue
                if marker == False:
                    message = "cyclic dependenencies detected at %r" % node
                    raise RuntimeError(message)
                mark[node] = False
                stack.append((node, True))
                if node not in graph:
                    continue
                for n in reversed(graph[node]):
                    if n not in mark:
                        stack.append((n, False))
        return tuple(result)

    def __get_component_info_database(self, toplevel_dir, order, debug_mode):
        db = ExternalComponentInfoDatabase()
        external = ExternalComponentInfo()
        external.index = 0
        external.name = 'external'
        external.branch = self.__get_external_branch(toplevel_dir)
        external.tag = self.__get_external_tag(toplevel_dir)
        external.remote_url = self.__get_external_url(toplevel_dir)
        external.work_dir = toplevel_dir
        db.components.append(external)
        for i, comp in enumerate(order):
            info = ExternalComponentInfo()
            info.index = i + 1
            info.name = comp
            info.branch = self.__get_component_dep_branch(toplevel_dir, comp)
            info.tag = self.__get_component_dep_tag(toplevel_dir, comp)
            info.remote_url = self.__get_component_dep_url(toplevel_dir, comp)
            info.work_dir = self.__get_component_work_dir(toplevel_dir, comp)
            db.components.append(info)
            if debug_mode and info.index >= 2:
                break
        return db

    def __log_updating_order(self, db):
        import sys
        string = 'Updating order:\n%s' % db
        print(string, file=sys.stderr)

    def __get_component_external_path(self, info):
        import os
        external_path = os.path.join(info.work_dir, 'external')
        if os.path.isdir(external_path):
            return external_path
        external_path = os.path.join(info.work_dir, '3rdparty', 'ml-external')
        if os.path.isdir(external_path):
            return external_path
        return None

    def __checkout_repository(self, db, info):
        import os
        import sys
        import subprocess
        if not os.path.isdir(info.work_dir):
            print('clone %s into %s ...' % (info.remote_url, info.work_dir), file=sys.stderr)
            args = 'git', 'clone',
            args += '--single-branch', '--branch', info.branch,
            args += '--depth', '10',
            args += info.remote_url, info.work_dir,
            subprocess.check_call(args)
        with work_dir(info.work_dir):
            args = 'git', 'checkout', info.branch
            subprocess.check_call(args)
            args = 'git', 'reset', 'origin/%s' % info.branch
            subprocess.check_call(args)
            args = 'git', 'checkout', '.'
            subprocess.check_call(args)
            args = 'git', 'clean', '-dfx'
            subprocess.check_call(args)
            args = 'git', 'pull', '--ff-only'
            subprocess.check_call(args)
            args = 'git', 'submodule', 'init'
            subprocess.check_call(args)
            external_path = self.__get_component_external_path(info)
            if external_path is not None:
                rel_external_path = os.path.relpath(external_path)
                args = 'git', 'config', 'submodule.%s.url' % rel_external_path, db.external.work_dir
                subprocess.check_call(args)
                args = 'git', 'submodule', 'update', '--recommend-shallow', '--', rel_external_path
                subprocess.check_call(args)

    def __checkout_repositories(self, db):
        for info in db.components:
            self.__checkout_repository(db, info)

    def __get_component_current_tag(self, info):
        import os
        import subprocess
        with work_dir(info.work_dir):
            args = 'git', 'pull', '--ff-only'
            subprocess.check_call(args)
            args = 'git', 'rev-parse', 'HEAD'
            output = subprocess.check_output(args)
            return output.strip()

    def __update_component_tag(self, info):
        info.tag = self.__get_component_current_tag(info)

    def __update_external_tag(self, db):
        db.external.tag = self.__get_external_tag(db.external.work_dir)

    def __get_current_local_time(self):
        import time
        now_ss_cn = time.time() + 3600 * 8
        now_ts_cn = time.gmtime(now_ss_cn)
        now_string = time.strftime('%Y-%m-%d %H:%M:%S', now_ts_cn)
        return now_string

    def __add_sync_note_on_external(self, db, is_begin):
        import os
        import sys
        import subprocess
        with work_dir(db.external.work_dir):
            self.__update_external_tag(db)
            verb = 'Begin' if is_begin else 'End'
            now_string = self.__get_current_local_time()
            t = verb, db.external.branch, db.external.tag, now_string, db
            string = '%s sync external: %s@%s at %s.\n\n%s' % t
            print(string, file=sys.stderr)
            args = 'git', 'commit', '--allow-empty', '-m', string
            subprocess.check_call(args)
            self.__update_external_tag(db)

    def __add_begin_note_on_external(self, db):
        self.__add_sync_note_on_external(db, True)

    def __add_end_note_on_external(self, db):
        self.__add_sync_note_on_external(db, False)

    def __update_docker_versions(self, db):
        import re
        import subprocess
        with work_dir(db.external.work_dir):
            versions_path = 'docker/VERSIONS'
            with open(versions_path) as fin:
                content = fin.read()
            short_tag = db.external.tag[:7]
            pattern = r"EXTERNAL_VERSION='(.+)'"
            repl = "EXTERNAL_VERSION='%s'" % short_tag
            new_content = re.sub(pattern, repl, content)
            with open(versions_path, 'w') as fout:
                fout.write(new_content)
            args = 'git', 'add', versions_path
            subprocess.check_call(args)
            string = 'Update EXTERNAL_VERSION to %s.' % short_tag
            args = 'git', 'commit', '--allow-empty', '-m', string
            subprocess.check_call(args)
            self.__update_external_tag(db)

    def __update_external_component_ref(self, db, info):
        import os
        import subprocess
        with work_dir(db.external.work_dir):
            check_cmake_path = os.path.join(db.external.work_dir, info.name, 'check.cmake')
            self.__update_component_dep_tag(check_cmake_path, info.tag)
            rel_check_cmake_path = os.path.relpath(check_cmake_path)
            args = 'git', 'add', rel_check_cmake_path
            subprocess.check_call(args)
            now_string = self.__get_current_local_time()
            t = info.name, info.branch, info.tag, now_string
            string = 'Update %s: %s@%s at %s.' % t
            args = 'git', 'commit', '--allow-empty', '-m', string
            subprocess.check_call(args)
            self.__update_external_tag(db)

    def __update_repository(self, db, info):
        import os
        import subprocess
        with work_dir(info.work_dir):
            external_path = self.__get_component_external_path(info)
            if external_path is not None:
                with work_dir(external_path):
                    args = 'git', 'fetch'
                    subprocess.check_call(args)
                    args = 'git', 'checkout', db.external.tag
                    subprocess.check_call(args)
                    args = 'git', 'checkout', '.'
                    subprocess.check_call(args)
                    args = 'git', 'clean', '-dfx'
                    subprocess.check_call(args)
                rel_external_path = os.path.relpath(external_path)
                args = 'git', 'add', rel_external_path
                subprocess.check_call(args)
                now_string = self.__get_current_local_time()
                t = db.external.branch, db.external.tag, now_string
                string = 'Update external: %s@%s at %s.' % t
                args = 'git', 'commit', '--allow-empty', '-m', string
                subprocess.check_call(args)
        self.__update_component_tag(info)
        self.__update_external_component_ref(db, info)

    def __update_repositories(self, db):
        self.__add_begin_note_on_external(db)
        for info in db.components:
            if info is not db.external:
                self.__update_repository(db, info)
        self.__add_end_note_on_external(db)
        self.__update_docker_versions(db)

    def __push_repository(self, db, info):
        import sys
        import subprocess
        for i in range(3):
            if i == 0:
                string = 'Try pushing to %s ...' % info.name
            elif i == 1:
                string = 'Retry pushing to %s ...' % info.name
            else:
                string = 'Retry pushing to %s again ...' % info.name
            print(string, file=sys.stderr)
            with work_dir(info.work_dir):
                args = 'git', 'push', '-u', 'origin', info.branch
                try:
                    subprocess.check_call(args)
                    print('\033[32mSucceed in pushing %s.\033[m' % info.name, file=sys.stderr)
                    return
                except subprocess.CalledProcessError:
                    pass
        else:
            print('\033[31mFail to push %s.\033[m' % info.name, file=sys.stderr)
            print('\nUpdates in the following repositories are not pushed:', file=sys.stderr)
            for comp in db.components:
                if comp.index >= info.index:
                    print('  %s' % comp.name, file=sys.stderr)
            raise SystemExit(1)

    def __push_repositories(self, db):
        for info in db.components:
            self.__push_repository(db, info)

    def run(self):
        import argparse
        parser = argparse.ArgumentParser(description="Synchorize external component versions")
        parser.add_argument('-d', '--debug-mode', action='store_true',
            help="debug mode; only process two front components")
        parser.add_argument('-u', '--update', action='store_true',
            help="actually update branches locally; by default, "
                 "the script just print updating order and exit")
        parser.add_argument('-p', '--push', action='store_true',
            help="push updates to remote branches")
        parser.add_argument('-m', '--update-mxnet', action='store_true',
            help="update external of mxnet")
        args = parser.parse_args()
        toplevel_dir = self.__get_toplevel_dir()
        comps = self.__parse_components(toplevel_dir)
        comps = self.__filter_components(toplevel_dir, comps, args.update_mxnet)
        graph = self.__build_dependency_graph(toplevel_dir, comps)
        order = self.__get_updating_order(toplevel_dir, graph)
        db = self.__get_component_info_database(toplevel_dir, order, args.debug_mode)
        self.__log_updating_order(db)
        if args.update:
            self.__checkout_repositories(db)
            self.__update_repositories(db)
            if args.push:
                self.__push_repositories(db)

def main():
    synchronizer = ExternalComponentVersionSynchronizer()
    synchronizer.run()

if __name__ == '__main__':
    main()

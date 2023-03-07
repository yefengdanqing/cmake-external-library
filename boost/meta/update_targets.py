#!/usr/bin/env python2.7
# -*- encoding: utf-8 -*-
# -*- mode: python -*-

from __future__ import print_function
from __future__ import absolute_import
from __future__ import division

import io
import os

def load_modules():
    cur_dir = os.path.dirname(__file__)
    file_path = os.path.join(cur_dir, 'modules.txt')
    with io.open(file_path, 'r', encoding='utf-8', newline='\n') as fin:
        return tuple(x.strip() for x in fin)

def load_buildable():
    cur_dir = os.path.dirname(__file__)
    file_path = os.path.join(cur_dir, 'buildable.txt')
    with io.open(file_path, 'r', encoding='utf-8', newline='\n') as fin:
        return tuple(x.strip() for x in fin)

def load_dependencies():
    cur_dir = os.path.dirname(__file__)
    file_path = os.path.join(cur_dir, 'dependencies.txt')
    with io.open(file_path, 'r', encoding='utf-8', newline='\n') as fin:
        deps = []
        for line in fin:
            head, tail = line.split(u'->')
            target = head.strip()
            sources = tuple(x.strip() for x in tail.split())
            deps.append((target, sources))
        return tuple(deps)

def get_interface_targets(modules, buildable):
    targets = []
    buildable_set = frozenset(buildable)
    for module in modules:
        if module not in buildable_set:
            targets.append(module)
    return tuple(targets)

def get_imported_targets(buildable, dependencies):
    targets = []
    buildable_set = frozenset(buildable)
    dependencies = dict(dependencies)
    for module in buildable:
        deps = []
        for dep in dependencies[module]:
            if dep in buildable_set:
                deps.append(dep)
        targets.append((module, tuple(deps)))
    return tuple(targets)

def format_target_name(name):
    return name.replace(u'~', u'_')

def format_target_dependency(dep):
    name = format_target_name(dep)
    if name == u'pthread':
        return u'pthread'
    if u'::' in name:
        return name
    if name == u'python':
        name = u'python2'
    elif name == u'stacktrace':
        name = u'stacktrace_addr2line'
    return u'boost::%s' % name

def output_interface_target(fout, target):
    name = format_target_name(target)
    cond = u'NOT TARGET boost::%s' % name
    print(u'if(%s)' % cond, file=fout)
    print(u'    add_library(boost::%s INTERFACE IMPORTED)' % name, file=fout)
    print(u'    set_target_properties(boost::%s PROPERTIES' % name, file=fout)
    print(u'        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")', file=fout)
    print(u'endif()', file=fout)

def output_boost_math_interface_target(fout, target):
    name = format_target_name(target)
    cond = u'NOT TARGET boost::%s' % name
    deps = u'boost::math_c99'
    deps += u';boost::math_c99f'
    deps += u';boost::math_c99l'
    deps += u';boost::math_tr1'
    deps += u';boost::math_tr1f'
    deps += u';boost::math_tr1l'
    print(u'if(%s)' % cond, file=fout)
    print(u'    add_library(boost::%s INTERFACE IMPORTED)' % name, file=fout)
    print(u'    set_target_properties(boost::%s PROPERTIES' % name, file=fout)
    print(u'        INTERFACE_LINK_LIBRARIES "%s"' % deps, file=fout)
    print(u'        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")', file=fout)
    print(u'endif()', file=fout)

def output_interface_targets(fout, targets):
    for i, target in enumerate(targets):
        output_interface_target(fout, target)
    output_boost_math_interface_target(fout, u'math')

def output_imported_target(fout, target, deps):
    name = format_target_name(target)
    path = u'${_DEP_LIB_DIR}/libboost_%s.a' % name
    cond = u'NOT TARGET boost::%s AND EXISTS %s' % (name, path)
    if name == u'thread':
        deps += u'pthread',
    libs = u';'.join(format_target_dependency(x) for x in deps)
    print(u'if(%s)' % cond, file=fout)
    print(u'    add_library(boost::%s STATIC IMPORTED)' % name, file=fout)
    print(u'    set_target_properties(boost::%s PROPERTIES' % name, file=fout)
    print(u'        IMPORTED_LOCATION "%s"' % path, file=fout)
    if libs:
        print(u'        INTERFACE_LINK_LIBRARIES "%s"' % libs, file=fout)
    if name == u'thread':
        print(u'        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"', file=fout)
        print(u'        INTERFACE_COMPILE_OPTIONS "-pthread")', file=fout)
    else:
        print(u'        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")', file=fout)
    print(u'endif()', file=fout)

def output_imported_targets(fout, targets):
    for i, (target, deps) in enumerate(targets):
        if target == u'python':
            output_imported_target(fout, target + u'2', deps + (u'python2::libpython',))
            output_imported_target(fout, target + u'3', deps + (u'python3::libpython',))
            output_imported_target(fout, u'numpy2', (u'python2',))
            output_imported_target(fout, u'numpy3', (u'python3',))
        elif target == u'stacktrace':
            output_imported_target(fout, target + u'_addr2line', deps)
            output_imported_target(fout, target + u'_basic', deps)
            output_imported_target(fout, target + u'_noop', deps)
        elif target == u'math':
            output_imported_target(fout, target + u'_c99', deps)
            output_imported_target(fout, target + u'_c99f', deps)
            output_imported_target(fout, target + u'_c99l', deps)
            output_imported_target(fout, target + u'_tr1', deps)
            output_imported_target(fout, target + u'_tr1f', deps)
            output_imported_target(fout, target + u'_tr1l', deps)
        else:
            output_imported_target(fout, target, deps)

def output_targets(interface_targets, imported_targets):
    cur_dir = os.path.dirname(__file__)
    file_path = os.path.join(cur_dir, 'targets.cmake')
    with io.open(file_path, 'w', encoding='utf-8', newline='\n') as fout:
        output_interface_targets(fout, interface_targets)
        print(u'', file=fout)
        output_imported_targets(fout, imported_targets)

def update_targets():
    modules = load_modules()
    buildable = load_buildable()
    dependencies = load_dependencies()
    interface_targets = get_interface_targets(modules, buildable)
    imported_targets = get_imported_targets(buildable, dependencies)
    output_targets(interface_targets, imported_targets)

def main():
    update_targets()

if __name__ == '__main__':
    main()

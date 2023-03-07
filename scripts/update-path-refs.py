#!/usr/bin/env python
# -*- encoding: utf-8 -*-
# -*- mode: python -*-

from __future__ import print_function
from __future__ import absolute_import
from __future__ import division

class PathReferencesUpdater(object):
    def __init__(self):
        self.__toplevel_dir = None
        self.__built_dir = None
        self.__source_dir = None
        self.__target_dir = None

    def __get_toplevel_dir(self):
        import os
        path = os.path.abspath(__file__)
        path = os.path.dirname(path)
        path = os.path.dirname(path)
        return path

    def run(self):
        import os
        import argparse
        parser = argparse.ArgumentParser(description="Update absolute external built paths")
        parser.add_argument('-b', '--built-dir', type=str, default=None,
            help="built dir; default to derive from script path")
        parser.add_argument('-s', '--source-dir', type=str, default=None,
            help="source install dir; default to derive from script path")
        parser.add_argument('-t', '--target-dir', type=str, default=None,
            help="target deploy dir; default to '/data/code/ml-platform-thirdparty'")
        args = parser.parse_args()
        toplevel_dir = self.__get_toplevel_dir()
        built_dir = args.built_dir
        if built_dir is None:
            built_dir = os.path.join(toplevel_dir, 'built')
        source_dir = args.source_dir
        if source_dir is None:
            source_dir = os.path.join(toplevel_dir, 'built')
        target_dir = args.target_dir
        if target_dir is None:
            target_dir = '/data/code/ml-platform-thirdparty'
        self.__toplevel_dir = toplevel_dir
        self.__built_dir = built_dir
        self.__source_dir = source_dir
        self.__target_dir = target_dir
        self.__update()

    def __filter_file_names(self):
        import os
        import sys
        def filter_dir(dir_path):
            for name in os.listdir(dir_path):
                item_path = os.path.join(dir_path, name)
                if os.path.isdir(item_path):
                    filter_dir(item_path)
                elif name.endswith('.cmake') or name.endswith('.pc'):
                    result.append(item_path)
        result = []
        filter_dir(self.__built_dir)
        return tuple(result)

    def __update_file_content(self, file_name):
        with open(file_name) as fin:
            content = fin.read()
        content = content.replace(self.__source_dir, self.__target_dir)
        with open(file_name, 'w') as fout:
            fout.write(content)

    def __update(self):
        import pprint
        file_names = self.__filter_file_names()
        for file_name in file_names:
            self.__update_file_content(file_name)

def main():
    updater = PathReferencesUpdater()
    updater.run()

if __name__ == '__main__':
    import os
    import sys
    import subprocess
    if os.geteuid() == 0:
        main()
    else:
        args = ['sudo', sys.executable] + sys.argv
        subprocess.check_call(args)

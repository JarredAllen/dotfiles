#!/usr/bin/python3

import os

def main(args):
    if len(args) != 1:
        usage()
        return 1
    empty_subdirs = list_empty_subdirs(args[0])[1]
    if empty_subdirs:
        print(*empty_subdirs, sep='\n')
    return 0

def usage():
    print("Usage: clean-empty-dirs.py <path>")

def list_empty_subdirs(root):
    """Outputs a tuple of (entirely empty?, [empty subdirs])
    
    The list does not contain nested directories (e.g. if foo and foo/bar
    are empty, it only contains foo).
    """
    entries = [f for f in os.scandir(root)]
    files = [f for f in entries if f.is_file() and not f.name.startswith(".")]
    subdirs = [f for f in entries if f.is_dir() and not f.name.startswith(".")]
    empty_subdirs = []
    all_subdirs_empty = True
    for subdir in subdirs:
        is_subdir_empty, empty_subsubdirs = list_empty_subdirs(subdir)
        all_subdirs_empty = all_subdirs_empty and is_subdir_empty
        empty_subdirs += empty_subsubdirs
    if files or not all_subdirs_empty:
        return (False, empty_subdirs)
    else:
        if type(root) is str:
            return (True, [root])
        else:
            return (True, [root.path])

if __name__ == '__main__':
    from sys import argv
    exit(main(argv[1:]))

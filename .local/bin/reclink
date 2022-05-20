#!/usr/bin/env python3
import sys

if sys.version_info.major != 3:
    print('please run with python 3')
    sys.exit(1)

import os
import logging
import argparse

logging.basicConfig(format='%(levelname)s %(message)s', level=logging.INFO)

SOURCE_DIR = str()
TARGET_DIR = str()
IGNORE_SET = {os.path.basename(__file__)}
REPLACE = False
DRY = False


# https://www.python.org/dev/peps/pep-0616/#specification
def removeprefix(text: str, prefix: str) -> str:
    if text.startswith(prefix):
        return text[len(prefix):]
    else:
        return text[:]


# https://www.python.org/dev/peps/pep-0616/#specification
def removesuffix(text: str, suffix: str) -> str:
    if text and text.endswith(suffix):
        return text[:-len(suffix)]
    else:
        return text[:]


def parse_args():
    parser = argparse.ArgumentParser(prog='reclink')

    required = parser.add_argument_group('required arguments')

    required.add_argument(
        '-s', '--source',
        action='store',
        type=str,
        required=True,
        metavar='PATH',
        help='path to source directory'
    )

    required.add_argument(
        '-t', '--target',
        action='store',
        type=str,
        required=True,
        metavar='PATH',
        help='path to target directory'
    )

    parser.add_argument(
        '-i', '--ignore',
        action='extend',
        type=str,
        nargs='+',
        required=False,
        metavar='PATH',
        help='relative paths to be ignored'
    )

    parser.add_argument(
        '-r', '--replace',
        action='store_true',
        required=False,
        help='replace existing targets'
    )

    parser.add_argument(
        '-q', '--quiet',
        action='store_true',
        required=False,
        help='skip user confirmation'
    )

    parser.add_argument(
        '-d', '--dry',
        action='store_true',
        required=False,
        help='skip actual changes to filesystem'
    )

    return parser.parse_args()


def link_file(source: str):
    # absolute path
    target = os.path.abspath(TARGET_DIR + os.sep + removeprefix(text=source, prefix=SOURCE_DIR))
    # check target
    if os.path.exists(target):
        if not REPLACE:
            logging.info('skipping link, target already exists: ' + target)
            return
        if os.path.isdir(target):
            logging.warning('skipping link, target is a directory: ' + target)
            return
        elif os.path.isfile(target) or os.path.islink(target):
            if not DRY:
                os.remove(target)
    else:
        if not os.path.isdir(os.path.abspath(target + os.sep + '..')):
            logging.info('creating directories for file: ' + target)
            if not DRY:
                try:
                    os.makedirs(removesuffix(text=target, suffix=os.path.basename(os.sep + target)), mode=0o755, exist_ok=True)
                except FileExistsError:
                    logging.warning('unable to create directory at: ' + os.path.abspath(target + os.sep + '..'))
                    return
    logging.info('linking file: ' + source + ' to ' + target)
    if not DRY:
        os.symlink(source, target)


def is_ignored(abs_path: str):
    rel_path = removeprefix(text=abs_path, prefix=SOURCE_DIR + os.sep)
    for i in IGNORE_SET:
        if rel_path == i or rel_path.startswith(i + os.sep):
            return True
    return False


if __name__ == '__main__':

    args = parse_args()

    SOURCE_DIR = os.path.abspath(args.source)
    TARGET_DIR = os.path.abspath(args.target)
    if args.ignore is not None:
        for i in args.ignore:
            IGNORE_SET.add(i)
    REPLACE = args.replace
    DRY = args.dry

    if not args.quiet:
        print('source: ' + str(SOURCE_DIR))
        print('target: ' + str(TARGET_DIR))
        print('ignore: ' + str(sorted(IGNORE_SET)))
        input('press enter to confirm')

    if not os.path.isdir(SOURCE_DIR):
        logging.error('source is not a directory: ' + SOURCE_DIR)
        sys.exit(2)

    if not os.path.isdir(TARGET_DIR):
        logging.error('target is not a directory: ' + TARGET_DIR)
        sys.exit(2)

    if SOURCE_DIR == TARGET_DIR:
        logging.error('source and target directory can not be the same')
        sys.exit(2)

    for root, _, files in os.walk(SOURCE_DIR):
        if is_ignored(root):
            logging.debug('ignoring folder: ' + str(root))
            continue
        for f in files:
            path = os.path.abspath(root + os.sep + f)
            if is_ignored(path):
                logging.debug('ignoring file: ' + str(path))
                continue
            link_file(path)

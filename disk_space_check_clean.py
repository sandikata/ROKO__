#!/usr/bin/python3
# Author: Rosen Aleksandrov
# E-Mail: rosen@aleksandrov.tech
# License: GPLv3

import datetime
import os
import sys
import shutil

#  Partitions to be checked
os_total, os_used, os_free = shutil.disk_usage("/")
aux1_total, aux1_used, aux1_free, = shutil.disk_usage("/aux1")
var_log_total, var_log_used, var_free = shutil.disk_usage("/var/log")

#  Common vars
os_total_space = (os_total // (2**30))  # partition total space
aux1_total_space = (aux1_total // (2**30))  # partition total space
var_log_total_space = (var_log_total // (2**30))  # partition total space
os_free_space = (os_free // (2**30))  # partition available space
aux1_free_space = (aux1_free // (2**30))  # partition available space
var_log_free_space = (var_free // (2**30))  # partition available space
os_used_space = os_used // 2**30  # used partition space
aux1_used_space = aux1_used // 2**30  # used partition space
var_log_used_space = var_log_used // 2**30  # used partition space
os_used_space_80 = os_used * 0.8 // 2**30  # 80% of partition space
aux1_used_space_80 = aux1_used * 0.8 // 2**30  # 80% of partition space
var_log_used_space_80 = var_log_used * 0.8 // 2**30  # 80% of partition space


def del_older_files(req_path):
    if os_used_space < os_used_space_80 or aux1_used_space < aux1_used_space_80 \
                        or var_log_used_space < var_log_used_space_80:
        sys.exit(1)
    else:
        n = int(input("Please provide period in days: "))
    if not os.path.exists(req_path):
        print("Please provide valid full path")
        sys.exit(2)
    if os.path.isfile(req_path):
        print("Please provide dictionary path")
        sys.exit(3)
    today = datetime.datetime.now()
    for each_file in os.listdir(req_path):
        each_file_path = os.path.join(req_path, each_file)
        if os.path.isfile(each_file_path):
            file_cre_date = datetime.datetime.fromtimestamp(os.path.getctime(each_file_path))
            dif_days = (today-file_cre_date).days
            if dif_days > n:
                os.remove(each_file_path)
                print(each_file_path, dif_days)


req_path = input("Please provide full path: ")
del_older_files(req_path)

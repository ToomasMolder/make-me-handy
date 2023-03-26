#!/bin/bash
###################################################################
# Script Name   : replace_apt.sh
# Script version: 1.01
# Script date   : 2023-01-06
# Description   : CHA-2212, Replace APT source, delete duplicates, cleanup specifics
# Author        : Toomas Mölder
# Email         : toomas.molder+makemehandy@gmail.com
###################################################################

# Similar approach using Ansible
: <<'END'
---
- name: Replace xxx with yyy 
  hosts: all
  gather_facts: false
  vars:
    not_need_files:
      - /etc/apt/sources.list.d/zz1.list
      - /etc/apt/sources.list.d/zz2.list
  tasks:
    - name: Find all APT source files
      ansible.builtin.find:
        paths: /etc/apt/sources.list.d
        patterns:
          - '*.list'
      register: source_files

    - name: Replace xxx with yyy
      ansible.builtin.replace:
        path: "{{ item.path }}"
        regexp: 'xxx'
        replace: 'yyy'
      with_items: "{{ source_files.files }}"

    - name: Remove not needed APT source files
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: absent
      with_items: "{{ source_files.files }}"
      when: item.path in not_need_files
END

# mkdir --parents ~/_etc_apt_sources_list_d; 
find_this="xxx"; 
replace_with="yyy"; 

tmp_file="${TMPDIR:-/tmp}/replace_tmp_file.$$";
source_dir="/etc/apt/sources.list.d"
backup_dir="./_etc_apt_sources_list_d"

echo "=== Current ${source_dir}/*.list ==="
ls --all -l --reverse --time=ctime "${source_dir}"/*.list

# :1,$s#xxx#yyy#
for file in $(grep --dereference-recursive "${find_this}" "${source_dir}" | \
  cut --delimiter=':' --fields=1 | \
  grep "\.list$" | sort | uniq);
do
  echo "Replace in ${file} ...";
  mkdir --parents "${backup_dir}"; 
  cp --preserve "${file}" "${backup_dir}"/; 
  # Replace and delete duplicate lines
  # Use '#' as separator in sed because ${find_this} and ${replace_with} already contains default '/'
  sed -e "s#${find_this}#${replace_with}#" "${file}" | sort | uniq > "${tmp_file}" && sudo mv "${tmp_file}" "${file}";
  sudo chown root:root "${file}";
done; 

# Cleanup specifics
f1="/etc/apt/sources.list.d/zz1.list"
f2="/etc/apt/sources.list.d/zz2.list"
# echo "Cleanup1 ${f1}"
if test -f "${f1}" && ! test -f "${f2}"; then echo "=== mv ${f1} ${f2} ==="; sudo mv --interactive "${f1}" "${f2}"; fi
# echo "Cleanup2 ${f1}"
if test -f "${f1}" && test -f "${f2}"; then echo "=== cat ${f1} ==="; cat "${f1}"; echo "=== cat ${f2} ==="; cat "${f2}"; echo "=== DIFF ==="; diff "${f1}" "${f2}"; sudo rm --interactive "${f1}"; fi

f1="/etc/apt/sources.list.d/zz7.list"
f2="/etc/apt/sources.list.d/zz8.list"
# echo "Cleanup ${f1}"
if test -f "${f1}" && test -f "${f2}"; then echo "=== cat ${f1} ==="; cat "${f1}"; echo "=== cat ${f2} ==="; cat "${f2}"; echo "=== DIFF ==="; diff "${f1}" "${f2}"; sudo rm --interactive "${f1}"; fi

f1="/etc/apt/sources.list.d/zz3.list"
f2="/etc/apt/sources.list.d/zz4.list"
# echo "Cleanup ${f1}"
if test -f "${f1}" && test -f "${f2}"; then echo "=== cat ${f1} ==="; cat "${f1}"; echo "=== cat ${f2} ==="; cat "${f2}"; echo "=== DIFF ==="; diff "${f1}" "${f2}"; sudo rm --interactive "${f1}"; fi

f1="/etc/apt/sources.list.d/zz5.list"
f2="${backup_dir}"/"$(basename -- ${f1})".save
# echo "Cleanup ${f1} to ${f2}"
if test -f "${f1}"; then sudo mv --interactive "${f1}" "${f2}"; fi

f1="/etc/apt/sources.list.d/zz6.list"
f2="${backup_dir}"/"$(basename -- ${f1})".save
# echo "Cleanup ${f1} to ${f2}"
if test -f "${f1}"; then sudo mv --interactive "${f1}" "${f2}"; fi

echo "=== Backup ${backup_dir}/ ==="
ls --all -l --reverse --time=ctime "${backup_dir}"/

echo "=== New ${source_dir}/*.list ==="
ls --all -l --reverse --time=ctime "${source_dir}"/*.list

echo "=== Check ==="
grep --dereference-recursive "${find_this}" "${source_dir}"

echo "=== Do we have still some crap ==="
ls -l --reverse --time=ctime --ignore="*.list" "${source_dir}"
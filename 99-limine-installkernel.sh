#!/bin/bash
# /etc/portage/bashrc.d/99-limine-installkernel.sh
# Генерира limine.conf за всички ядра, с module_path и kernel params
# Всеки run има отделен log файл
# Презаписва limine.conf при всяко изпълнение

case "${EBUILD_PHASE}" in
    postinst)
        # ESP / limine.conf
        ESP=$(findmnt -n -o TARGET -t vfat /boot 2>/dev/null || true)
        [ -z "$ESP" ] && ESP=/boot
        LIMINE_CFG="$ESP/limine.conf"

        # Лог на текущото изпълнение
        KVER=$(basename /lib/modules/* | tail -n1)
        LOGFILE="/var/log/portage/limine-installkernel-${KVER}.log"
        echo "=== Limine hook for kernel $KVER started at $(date) ===" > "$LOGFILE"
        exec >>"$LOGFILE" 2>&1

        echo "ESP detected: $ESP"
        echo "Limine config: $LIMINE_CFG"

        # Глобални kernel parameters
        EXTRA_CMDLINE="amd_pstate=passive amdgpu.ppfeaturemask=0xffffffff amdgpu.vm_update_mode=0 amdgpu.gpu_recovery=1 amdgpu.dc=1 ipv6.disable=1 msr.allow_writes=on net.ifnames=0 psi=1 drm_kms_helper.poll=0 apparmor=1 security=apparmor lsm=landlock,lockdown,yama,integrity,apparmor pcie_aspm=off pcie_port_pm=off idle=nomwait processor.max_cstate=1 nvme_core.default_ps_max_latency_us=0 nvme_core.io_timeout=15 nvme_core.admin_timeout=15 quiet splash"

        # Сканираме всички BLS-style kernel файлове
        mapfile -t KERNELS < <(find "$ESP" -mindepth 2 -type f -name linux | sort)
        [ ${#KERNELS[@]} -eq 0 ] && { echo "No kernels found, exiting"; exit 0; }

        echo "Found kernels:"
        printf '%s\n' "${KERNELS[@]}"

        # Презаписваме limine.conf (чисто нов файл)
        > "$LIMINE_CFG"

        # Default + rollback
        LAST_INDEX=$((${#KERNELS[@]} - 1))
        DEFAULT_KERNEL="${KERNELS[$LAST_INDEX]}"
        ROLLBACK_KERNEL="${KERNELS[$LAST_INDEX-1]:-$DEFAULT_KERNEL}"

        echo "Default kernel: $DEFAULT_KERNEL"
        echo "Rollback kernel: $ROLLBACK_KERNEL"

        # Функция за добавяне на entry
        add_entry() {
            local KPATH="$1"
            VER=$(basename "$(dirname "$KPATH")")
            INIT="$(dirname "$KPATH")/initrd"

#            printf "/Linux\n\
            printf "/Gentoo $VER\n
            protocol: linux\n\
            kernel_path: boot():/%s\n" "${KPATH#$ESP/}" >> "$LIMINE_CFG"

            [ -f "$INIT" ] && printf "    module_path: boot():/%s\n" "${INIT#$ESP/}" >> "$LIMINE_CFG"

            ROOT_UUID=$(blkid -s UUID -o value "$(findmnt -n -o SOURCE /)")
            [ -n "$ROOT_UUID" ] && \
            printf "    cmdline: root=UUID=%s rw %s\n" "$ROOT_UUID" "$EXTRA_CMDLINE" >> "$LIMINE_CFG"

            printf "    comment: Gentoo Linux %s\n\n" "$VER"
        }

        # Добавяме default и rollback първо
        add_entry "$DEFAULT_KERNEL"
        [ "$ROLLBACK_KERNEL" != "$DEFAULT_KERNEL" ] && add_entry "$ROLLBACK_KERNEL"

        # Добавяме останалите ядра
        for idx in $(seq 0 $((LAST_INDEX-2))); do
            add_entry "${KERNELS[$idx]}"
        done

        echo "Limine.conf updated successfully."
        ;;
esac


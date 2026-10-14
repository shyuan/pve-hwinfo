# pve-hwinfo

在 Proxmox VE 9.2 節點的 Summary 頁多顯示三列：CPU 各核心時脈、溫度（hwmon）、NVMe SMART。

做法與設計說明：[Proxmox VE 9.2 Summary 頁顯示溫度、CPU 時脈與 NVMe SMART：給 homelab 的安全 patch 做法](https://blog.chrisyuan.me/posts/proxmox-ve-summary-cpu-freq-temperature-nvme-smart/)

## 運作方式

- 溫度與時脈直接讀 sysfs（`/sys/class/hwmon`、`/sys/devices/system/cpu/cpuN/cpufreq`），不需要 lm-sensors
- NVMe SMART 由 root 的 systemd timer 每 5 分鐘跑 `smartctl -a -j`，寫入 `/run/pve-hwinfo/nvme.json`；不需要 setuid
- patch `/usr/share/perl5/PVE/API2/Nodes.pm` 與 `/usr/share/pve-manager/js/pvemanagerlib.js`，注入內容夾在 `pve-hwinfo BEGIN` / `END` 標記之間，可重複套用、可完整還原
- `/etc/apt/apt.conf.d/99pve-hwinfo` 在每次 dpkg 執行後跑 `pve-hwinfo apply --if-needed`，pve-manager 升級後自動補回

## 安裝

在 PVE 節點上以 root 執行：

```bash
apt install -y git   # PVE 預設沒有 git
cd /root
git clone https://github.com/shyuan/pve-hwinfo.git
bash pve-hwinfo/install.sh
```

裝好後重新整理瀏覽器（必要時清除快取），節點 Summary 頁會出現「CPU 時脈」、「溫度」、「NVMe SMART」三列。

叢集的其他節點可以從已安裝的節點推送（使用叢集內建的 root SSH）：

```bash
bash /root/pve-hwinfo/deploy.sh <node> [<node> ...]
```

## 指令

```
pve-hwinfo apply [--if-needed]   重新套用 patch，reload pveproxy
pve-hwinfo restore               移除 patch，reload pveproxy
pve-hwinfo status                顯示 patch、timer、NVMe cache 狀態
pve-hwinfo uninstall             還原並移除所有安裝的檔案
```

## 驗證

```bash
pve-hwinfo status
pvesh get /nodes/$(hostname)/status --output-format json   # 應含 hwinfo 欄位
```

## 注意

這個工具會修改 PVE 自帶的檔案。注入點的 regex 在新版 pve-manager 找不到時，`apply` 會中止並回滾，Summary 頁只是不顯示這三列。只在 PVE 9.2 上測試過。

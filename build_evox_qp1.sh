echo " ____ _____  _    ____ _____ ___ _   _  ____ "
echo "/ ___|_   _|/ \  |  _ \_   _|_ _| \ | |/ ___|"
echo "\___ \ | | / _ \ | |_) || |  | ||  \| | |  _ "
echo " ___) || |/ ___ \|  _ < | |  | || |\  | |_| |"
echo "|____/ |_/_/   \_\_| \_\|_| |___|_| \_|\____|"

# 1. Cleanup - Hapus folder manifest lama dan sisa build sebelumnya
echo ">>> Cleaning up old directories..."
remove_lists=(
  .repo/local_manifests
  device/xiaomi/emerald
  device/xiaomi/emerald-kernel
  vendor/xiaomi/emerald
  hardware/mediatek
  hardware/xiaomi
  out/target/product/emerald
)
rm -rf "${remove_lists[@]}"

# 2. Initialize Repo (Evolution X)
echo ">>> Starting Initializing Repo..."
repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/Evolution-X/manifest.git -b bq2 -g default,-mips,-darwin,-notdefault

# 3. Clone Local Manifests
# Pastikan lo udah bikin branch baru di repo local_manifest lo untuk emerald
echo ">>> Cloning Local Manifests for Emerald..."
git clone https://github.com/Renelzx/local_manifest.git --depth 1 -b emerald-16.0 .repo/local_manifests

# 4. Repo Sync
echo ">>> Starting Repo Sync..."
[ -f /usr/bin/resync ] && /usr/bin/resync || /opt/crave/resync.sh

# 5. Set up build environment
echo ">>> Setup Environment..."
export BUILD_USERNAME=renelzx 
export BUILD_HOSTNAME=nobody 
export TZ="Asia/Jakarta"
source build/envsetup.sh

# 6. Build the ROM
echo ">>> Starting Build for Emerald..."
lunch lineage_emerald-userdebug
m evolution

# 7. Check output
[ -d out ] && ls out/target/product/emerald

# Define installation steps
.PHONY: all setup install-packages test-i2c download-script setup-cron run-script

all: setup install-packages test-i2c download-script setup-cron

# Step 1: Setup Raspberry Pi environment
setup:
        @echo "Configuring Raspberry Pi settings..."
        @sudo raspi-config nonint do_i2c 0
        @echo "I2C interface enabled."

# Step 2: Install necessary packages
install-packages:
        @echo "Installing Python and I2C tools..."
        @sudo apt update
        @sudo apt install -y python3-pip python3-smbus i2c-tools
        @echo "Installing Python libraries..."
        @pip3 install --user adafruit-circuitpython-bme280 paho-mqtt
        @echo "All packages installed."

# Step 3: Test I2C connection
test-i2c:
        @echo "Testing I2C connection..."
        @lsmod | grep i2c_
        @sudo i2cdetect -y 1
        @echo "I2C connection tested. The BME280 should appear at address 76."

# Step 4: Download Python script to /usr/local/sbin/
download-script:
        @echo "Downloading Python script..."
        @sudo wget -O /usr/local/sbin/bme280.py https://github.com/alaub81/rpi_sensor_scripts/raw/main/bme280.py
        @sudo chmod +x /usr/local/sbin/bme280.py
        @echo "Python script downloaded and made executable."

# Step 5: Set up a cron job for running the script
setup-cron:
        @echo "Setting up cron job..."
        @echo "* * * * * root /usr/local/sbin/bme280.py >/dev/null 2>&1" | sudo tee /etc/cron.d/bme280_reading
        @echo "Cron job set up to run every minute."

# Step 6: Run the Python script to read sensor data
run-script:
        @echo "Running Python script to read from BME280..."
        @/usr/local/sbin/bme280.py


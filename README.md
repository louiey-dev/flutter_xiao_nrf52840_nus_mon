# flutter_xiao_nrf52840_nus_mon

Window BLE utility for xiao nrf52840 kit.
This is demo application with xiao_nrf52840_sense_peripheral_nus FW.
Based code is from "flutter_xterm_uart_split_window"

## TODOs

- Split window set up
- Basic code prepare
- Terminal feature
  - copy and paste window
  - keyboard input
- BLE basic connection feature
- universal_ble v1.0 apply
  - some differences at code

## History

- 2025.12.22
  - First commit
- 2025.12.29
  - RGB Led control toggle button added
    - it works with xiao evm
  - need to consider new UI screen to control BLE NUS
    - bluetooth screen includes toggle buttons and it looks not good

## Info

- Author : Louiey
- Flutter 3.35.7
- Target : xiao nrf52840 kit with xiao_nrf52840_sense_peripheral_nus SW

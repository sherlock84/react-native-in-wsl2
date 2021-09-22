# react-native-in-wsl2

## Introduction 

This repository provides a PowerShell script for React Native developers who want to work in Windows Subsystem Linux (WSL), especially with Android Studio and Android Emulators. As you may have already known, the problem with WSL, and WSL2 up to this moment of writing, is that we cannot create and run an Android Virtual Device (AVD) from within WSL environment. What we can only do is to start the Android emulators in Windows and make all the communications between the emulators with all other Android development components/services in WSL2 work. Configuring all of these to work might be a troublesome task. So I decided to create a PowerShell script to make our developer life easier.

## Usage

### Install Android Studio and configure for it to run with a GUI in WSL2.

You can follow the instructions in the following YouTube video to install Android Studio and run with a GUI from WSL2.
https://www.youtube.com/watch?v=XJ0dI2SYHIE

### Install Android Studio command line tools in Windows

The only thing we need to install in Windows is the command line tools from Android Studio. For more information, please visit https://developer.android.com/studio/command-line.

### Development workflow

1. In WSL2, navigate to your React Native project and start Android Studio. You may have to add Android Studio `bin` path to your `$PATH` environment variable for this command to work.

```bash
studio.sh android
```

If you don't want to use Android Studio, you can start an ADB server instance instead.

```bash
adb -a nodaemon server start
```

2. In Windows, open PowerShell in Administrative mode and run the script. Because the script runs many `netsh interface portproxy` commands to setup the port forwarding rules between the Windows host and the WSL2, it requires administrative privileges.

```powershell
wsl-react-native-port-forwarding.ps1
```
If you want to get update from Metro bundler from WSL2 (only for JavaScript changes) on your devices, you may want to run the script with a parameter indicating your network interface name where your device and your development computer can see each other. For example, in my case, I am using my Wi-Fi network so I will run

```powershell
wsl-react-native-port-forwarding.ps1 "Wi-Fi"
```

With that configuration, now I can get JavaScript bundle update from Metro bundler, even when I am using an iOS device. For iOS devices, it is required that we must have a MacOS computer with Xcode installed to develop native features. However, as long as there are no changes of native functions written in C/C++/Objective-C/Swift, we don't have to connect our devices to a MacOS computer. All we need to do is to run our app in Debug configuration and in the device, shake it to open Developer Menu, then change the bundler remote host to the LAN/WAN IP of the Windows computer.

3. In Windows, start an emulator instance. When starting up, the Android emulator instance will try to connect to an ADB server and start a new one in Windows host if it cannot connect. To avoid this situation, it is important to start an ADB server in WSL2 first, then setup all the port forwarding rules by running the script before executing this step.

```cmd
emulator.exe -avd <instance name>
```

3. In WSL2, connect to the Android emulator by running the following command. You can run `cat /etc/resolv.conf` to see what is the current WSL2 Windows host IP. `5555` should be the default ADB port of the Android emulator. If not please check its debug log to find the correct one.

```bash
adb connect <WSL2 Windows host IP>:5555
```

4. Verify by running `adb devices` from WSL2 to see the Android emulator instance connected.
5. Now you can work as usually with your React Native project in WSL2 along with Android Studio installed as well.

**NOTE** The PowerShell script uses a command that is specific to Ubuntu distro to find the current IP of the WSL2 instance. If you are using a different distro, you can replace it with whatever suitable.

Happy coding!

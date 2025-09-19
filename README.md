<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/8/82/Gnu-bash-logo.svg" alt="IP Rotator Logo" width="120"/>
</p>

<h1 align="center">🔄 IP Rotator</h1>

<p align="center">
  <em>A lightweight Bash script that randomly changes your network interface’s IP address and restores the original when stopped.</em>
</p>

---

## ⚡ Features
- Save and restore original IP, subnet mask, and gateway.
- Generate random private IPs.
- Rotate IPs automatically every 5 seconds.
- Start/Stop with one command.

---

## 📦 Usage
```bash
./ip-rotator.sh <interface> <start|stop>
```

---

▶️ Start rotating
```bash
./ip-rotator.sh eth0 start
```

---

⏹ Stop rotating

```bash
./ip-rotator.sh eth0 stop
```

---
📝 Example Output
```vbnet
Saved: IP=192.168.1.50 Mask=24 GW=192.168.1.1
Rotating IP every 5s on eth0 (Ctrl+C to stop)
Changing to: 10.33.141.77/24 GW:10.33.141.1
OK: 10.33.141.77
Changing to: 172.20.55.94/24 GW:172.20.55.1
OK: 172.20.55.94
Changing to: 192.168.129.200/24 GW:192.168.129.1
OK: 192.168.129.200
```

---

<p align="center">⭐ If you like this project, give it a star!</p> <p align="center">💻 Made with ❤️ by Ahmad</p>

# nmap-nse-scripts
A few NSE scripts I've built for one task or another

# Usage
```bash
  # Quickly scan a target for Cloudify REST API (HTTP)
  nmap -Pn -n -p 80 --open --script="cloudify" <target>
```

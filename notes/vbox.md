# Creating a VM

- Check the [./performance.md](./performance.md) document for host and VM changes
- After installation, remove disk
- Use bride network adaptor
- Setup ssh to use common key and don't allow password

```bash
rsync -rhv --delete ./ igncp@192.168.1.X:/home/igncp/environment/
```

- If using UI, check if audio is muted
- For full-screen press Ctrl+f

## USB

Menu > Machine > USB > Add new filter: Choose the USB to add

## Headless

```bash
VBoxHeadless \
  --startvm "$VM_NAME"
```

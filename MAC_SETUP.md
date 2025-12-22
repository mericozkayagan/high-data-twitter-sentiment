# Mac Setup Notes

## Quick Start

1. **Make scripts executable:**
   ```bash
   chmod +x scripts/*.sh
   ```

2. **Setup environment:**
   ```bash
   ./scripts/setup_environment.sh
   ```

3. **Start Kafka:**
   ```bash
   ./scripts/start_kafka.sh
   ```

4. **Create topics:**
   ```bash
   ./scripts/create_topics.sh
   ```

## Notes

- All shell scripts use `python3` instead of `python`
- Path separators use `/` (Unix-style)
- Virtual environment activation uses `source venv/bin/activate`
- Docker commands are the same across platforms

## Troubleshooting

### Permission Denied
If you get "permission denied" errors:
```bash
chmod +x scripts/*.sh
```

### Python3 Not Found
Make sure Python 3 is installed:
```bash
python3 --version
```

If not installed:
```bash
brew install python3
```

### Docker Not Running
Start Docker Desktop before running scripts.


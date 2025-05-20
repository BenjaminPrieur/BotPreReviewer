# BotPreReviewer

## Setup

### Running as a Scheduled Task

To run the bot every 5 minutes using crontab:

1. Open your crontab:
```bash
crontab -e
```

2. Add this line (adjust the path to match your workspace):
```bash
*/5 * * * * cd <ROOT_PROJECT_PATH>/BotReviewer && swift run BotReviewer -u <USERNAME> -t <TOKEN>
```

3. Save and exit. The bot will now run every 5 minutes.

To check if it's working:
```bash
# View crontab entries
crontab -l

# Check system logs for any errors
grep CRON /var/log/system.log
```

To stop the scheduled task:
```bash
crontab -r  # Removes all crontab entries
```

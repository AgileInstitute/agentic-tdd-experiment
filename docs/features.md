# Feature Notes

## Local User Backups

To address the "what if my home server goes away" problem inherent in ActivityPub's server-tied identity model:

- Users can take frequent, automated local backups of their data
- Backups are incremental/differential rather than full dumps (like Facebook's export, but smarter)
- This gives users data portability without depending on AT Protocol's more complex portable identity model

### Needs specs covering:
- Backup frequency / scheduling
- Backup format
- Restore flow
- Partial (differential) backup behavior

# Lending POC - Project Configuration

## Salesforce Org Connection

This project is connected to a Salesforce Developer org:

- **Org Alias**: lending-poc
- **Org ID**: 00DgK00000A9SVcUAN  
- **Username**: robinjosephparfan691@agentforce.com
- **Instance URL**: https://orgfarm-99db23b830-dev-ed.develop.my.salesforce.com
- **API Version**: 64.0
- **Status**: Connected ✅

## Quick Commands

### Check org connection
```bash
sf org list
sf org display --target-org lending-poc
```

### Deploy metadata to org
```bash
sf project deploy start --target-org lending-poc
```

### Retrieve metadata from org
```bash
sf project retrieve start --target-org lending-poc
```

### Open org in browser
```bash
sf org open --target-org lending-poc
```

## Project Structure
- `/force-app/main/default/` - Salesforce metadata
- `/docs/` - Project documentation
- `/scripts/` - Build and deployment scripts

## Development Notes
- The org is a Developer Edition (non-source tracked)
- Default org is set to `lending-poc`
- Project uses API version 64.0
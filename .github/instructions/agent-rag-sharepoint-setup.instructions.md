**RAG Reference:** [Retrieval-augmented Generation with SharePoint - Microsoft Learn](https://learn.microsoft.com/en-us/azure/search/search-solutions-retrieval-augmented-generation)

**Purpose:** Setup complete SharePoint integration (both modes) with no manual intervention except optional Azure portal config.

**User Entry:** `copilot-cli run .github/agents/rag-sharepoint-setup.agent.md`

**Expected Duration:** 5-15 minutes (depending on mode and document size)

---

## âœ… Setup Checklist

- [ ] Azure AD app registered (link provided if needed)
- [ ] Tenant ID & Client ID obtained
- [ ] SharePoint site URL identified
- [ ] (Optional) Client Secret for service principal
- [ ] (Local mode) Enough disk space for download
- [ ] (Professional mode) Azure Search instance deployed

---

## Phase-by-Phase Implementation

### Phase 1: Pre-Flight Check (1 min - AUTO)

```python
# Check prerequisites
checks = {
    "Python 3.10+": check_python_version(),
    "msal installed": check_package("msal"),
    "requests installed": check_package("requests"),
    "tqdm installed": check_package("tqdm"),
    "Azure CLI logged in": check_azure_cli(),
    "Knowledge folder exists": check_path("knowledge/"),
}

print("Pre-Flight Checks:")
for check, result in checks.items():
    print(f"  {'âœ…' if result else 'âœ—'} {check}")

if not all(checks.values()):
    print("Install missing: pip install -r .github/requirements.txt")
    exit(1)
```

### Phase 2: Interview User (2 min - INTERACTIVE)

```python
print("\n" + "="*50)
print("SHAREPOINT INTEGRATION SETUP")
print("="*50)

# Question 1: Azure AD app
q1 = ask_user(
    "Have you registered an app in Azure AD?",
    choices=["Yes", "No", "I don't know"],
)
if q1 == "No" or q1 == "I don't know":
    print("""
    âš  Setup Required First:
    
    1. Go to: https://portal.azure.com
    2. Search: "App registrations"
    3. Click: "New registration"
       - Name: "RAG SharePoint Connector"
       - Redirect URI: http://localhost:8000
    4. Click: "Register"
    5. Go to: API Permissions
    6. Click: "Add permission"
       - Microsoft Graph → Sites.Read.All
       - Microsoft Graph → Files.Read.All
       - Microsoft Graph → offline_access
    7. Click: "Grant admin consent"
    8. Go to: Certificates & secrets
    9. Copy: "Application (client) ID"
    10. Go to: Azure AD → Properties, copy "Directory ID"
    
    Then come back and run this script again.
    """)
    exit(0)

# Question 2: Mode selection
mode = ask_user(
    "Which mode?",
    choices=["Professional (real-time, recommended)", "Local (download)"],
)
mode = "professional" if "Professional" in mode else "local"

# Question 3: SharePoint URL
sharepoint_url = ask_user("SharePoint site URL:")
# Format check
if not sharepoint_url.startswith("https://") or "sharepoint.com" not in sharepoint_url:
    print("âœ— Invalid URL. Should be like: https://contoso.sharepoint.com/sites/Docs")
    exit(1)

# Question 4: Tenant ID
tenant_id = ask_user("Tenant ID (from Azure AD → Properties → Directory ID):")

# Question 5: Client ID
client_id = ask_user("Client ID (from App registration → Overview):")

# Question 6: Client Secret (optional)
use_secret = ask_user(
    "Do you have a Client Secret? (for service principal, leave empty for interactive)",
    choices=["Yes", "No"],
)
client_secret = None
if use_secret == "Yes":
    print("âš  Enter Client Secret (will NOT be shown, press Enter when done):")
    import getpass
    client_secret = getpass.getpass()

print("\n✓ Configuration captured")
```

### Phase 3: Authenticate (2 min - AUTO)

```python
from sharepoint_auth import SharePointAuthenticator

print("\n" + "="*50)
print("AUTHENTICATION")
print("="*50)

auth = SharePointAuthenticator(tenant_id, client_id, client_secret)

if client_secret:
    print("\nâ„¹ Using Service Principal authentication...")
    config = auth.authenticate_service_principal()
else:
    print("\nâ„¹ Opening browser for interactive login...")
    config = auth.authenticate_interactive()

print("âœ… Authentication successful!")
print(f"   Token expires: {config.token_expires_at}")

# Save token to file (for future reuse)
config_file = Path("scripts/sharepoint-auth-cache.json")
config_file.parent.mkdir(exist_ok=True)
auth.save_config(config_file)
print(f"   Config cached: {config_file}")
```

### Phase 4: Resolve SharePoint Site (1 min - AUTO)

```python
from sharepoint_connector import SharePointConnector

print("\n" + "="*50)
print("SITE RESOLUTION")
print("="*50)

print(f"\nResolving: {sharepoint_url}")

connector = SharePointConnector(config, mode=mode)
site_info = connector.resolve_sharepoint_site(sharepoint_url)

print(f"\n✓ Site found:")
print(f"   Name: {site_info['display_name']}")
print(f"   Site ID: {site_info['site_id']}")
print(f"   Drive ID: {site_info['drive_id']}")
```

### Phase 5: Count Documents (1 min - AUTO)

```python
print("\n" + "="*50)
print("DOCUMENT DISCOVERY")
print("="*50)

print("\nScanning all documents and folders...")

items = connector.list_all_items_recursive()

total_size = sum(item["size"] for item in items)
print(f"\nâœ… Found: {len(items)} documents")
print(f"   Total size: {total_size / 1024 / 1024 / 1024:.1f} GB")

# Ask for confirmation if large
if len(items) > 10000:
    confirm = ask_user(
        f"Large number of documents ({len(items)}). Continue anyway?",
        choices=["Yes", "No"],
    )
    if confirm == "No":
        print("Setup cancelled.")
        exit(0)
```

### Phase 6: Mode-Specific Setup

#### PROFESSIONAL MODE (2-3 min)

```python
if mode == "professional":
    print("\n" + "="*50)
    print("PROFESSIONAL MODE SETUP")
    print("="*50)
    
    print("""
    âœ… Professional mode will:
       • Create indexer that syncs from SharePoint in real-time
       • Update Azure Search automatically (hourly)
       • No document duplication
    
    Next steps (MANUAL in Azure Portal):
    """)
    
    # Generate config for manual portal setup
    config = connector.setup_professional_mode()
    
    config_file = Path("scripts/sharepoint-indexer-config.json")
    with open(config_file, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2)
    
    print(f"""
    1. Open: https://portal.azure.com
    2. Go to: Search Service → Data sources
    3. Click: "+ Add data source"
    4. Fill form using: {config_file}
    
    5. Go to: Indexers
    6. Click: "+ Create indexer"
    7. Data source: SharePoint (created above)
    8. Index: rag-documents
    9. Skillset: (optional, use if you have one)
    10. Schedule: 1 hour (or custom)
    11. Save
    
    12. Run indexer manually first: Indexers → {config['indexer']['name']} → Run
    
    âœ… Check status: Indexers → History tab
    """)
    
    # Wait for user confirmation
    confirm = ask_user(
        "Have you created the indexer in Azure Portal?",
        choices=["Yes", "No"],
    )
    
    if confirm == "No":
        print("Setup paused. Come back when ready.")
        print(f"Config saved: {config_file}")
        exit(0)
```

#### LOCAL MODE (3-10 min)

```python
else:  # local mode
    print("\n" + "="*50)
    print("LOCAL MODE SETUP (DOWNLOAD)")
    print("="*50)
    
    print(f"""
    âœ… Local mode will:
       • Download all {len(items)} documents to knowledge/sharepoint-*/
       • Preserve folder structure
       • Work offline after download
       • Coexist with existing knowledge/ documents
       
    Downloading {total_size / 1024 / 1024 / 1024:.1f} GB...
    """)
    
    knowledge_dir = Path("knowledge")
    download_dir = connector.setup_local_mode(knowledge_dir)
    
    print(f"\nâœ… Download complete!")
    print(f"   Destination: {download_dir}")
    print(f"   Manifest: {download_dir / 'manifest.json'}")
```

### Phase 7: Index Documents (Local Mode Only)

```python
if mode == "local":
    print("\n" + "="*50)
    print("INDEXING")
    print("="*50)
    
    # Ask for automatic indexing
    auto_index = ask_user(
        "Index documents now?",
        choices=["Yes", "No"],
    )
    
    if auto_index == "Yes":
        print("\nRunning rag-indexer.py...")
        import subprocess
        result = subprocess.run(
            ["python", ".github/skills/rag-indexer/indexar.py"],
            cwd=Path("."),
        )
        
        if result.returncode == 0:
            print("âœ… Indexing complete!")
        else:
            print("âœ— Indexing failed. Run manually:")
            print("   python .github/skills/rag-indexer/indexar.py")
```

### Phase 8: Save Configuration (1 min - AUTO)

```python
print("\n" + "="*50)
print("CONFIGURATION")
print("="*50)

# Save full config
full_config = {
    "mode": mode,
    "sharepoint_url": sharepoint_url,
    "tenant_id": tenant_id,
    "client_id": client_id,
    "site_name": site_info["display_name"],
    "site_id": site_info["site_id"],
    "drive_id": site_info["drive_id"],
    "document_count": len(items),
    "total_size_gb": total_size / 1024 / 1024 / 1024,
    "setup_timestamp": datetime.now().isoformat(),
    "mode_config": config if mode == "professional" else {"download_dir": str(download_dir)},
}

config_file = Path("scripts/sharepoint-config.json")
config_file.parent.mkdir(exist_ok=True)
with open(config_file, "w", encoding="utf-8") as f:
    json.dump(full_config, f, indent=2)

print(f"\n✓ Configuration saved: {config_file}")

# Update .env
env_file = Path(".env")
if env_file.exists():
    with open(env_file, "a", encoding="utf-8") as f:
        f.write(f"\n# SharePoint Integration\n")
        f.write(f"SHAREPOINT_MODE={mode}\n")
        f.write(f"SHAREPOINT_URL={sharepoint_url}\n")
        f.write(f"SHAREPOINT_SITE={site_info['display_name']}\n")
    print(f"✓ .env updated with SharePoint settings")
```

### Phase 9: Validation (1 min - AUTO)

```python
print("\n" + "="*50)
print("VALIDATION")
print("="*50)

tests = {
    "Authentication": check_auth_token(),
    "SharePoint accessible": check_sharepoint_connection(),
    "Configuration saved": config_file.exists(),
}

for test, result in tests.items():
    status = "âœ…" if result else "âœ—"
    print(f"{status} {test}")

if not all(tests.values()):
    print("\nWarning: Some tests failed. Setup may not be complete.")
    exit(1)
```

### Phase 10: Summary & Next Steps (1 min - AUTO)

```python
print("\n" + "="*50)
print("âœ… SETUP COMPLETE")
print("="*50)

summary = {
    "Mode": mode.capitalize(),
    "SharePoint Site": site_info["display_name"],
    "Documents": len(items),
    "Total Size": f"{total_size / 1024 / 1024 / 1024:.1f} GB",
    "Config Saved": str(config_file),
}

for key, value in summary.items():
    print(f"{key}: {value}")

print("\n" + "="*50)
print("NEXT STEPS")
print("="*50)

if mode == "professional":
    print("""
    1. âï¸  MANUAL: Create indexer in Azure Portal
       - Use config: scripts/sharepoint-indexer-config.json
       - Set schedule: Hourly (or custom)
       - Run first sync manually
    
    2. Monitor: Azure Portal → Search Service → Indexers → Status
    
    3. Query documents:
       python .github/skills/rag-query-cli/consultar.py "your question"
    
    4. API mode:
       python .github/skills/rag-api-server/servidor-api.py --port 8000
       curl -X POST http://localhost:8000/query \\
         -H "Content-Type: application/json" \\
         -d '{"query": "your question"}'
    """)
else:  # local
    print("""
    1. ✓ Documents downloaded and indexed
    
    2. Query documents:
       python .github/skills/rag-query-cli/consultar.py "your question"
    
    3. API mode:
       python .github/skills/rag-api-server/servidor-api.py --port 8000
    
    4. Monitor:
       python .github/skills/rag-diagnostics/estado-sistema.py
    
    5. Schedule daily sync (optional):
       - Add to cron or Task Scheduler
       - Or modify scripts/sharepoint-sync.sh
    """)

print("\nFor full documentation: .github/skills/rag-sharepoint-connector/SKILL.md")
```

---

## Error Recovery

### Authentication Errors

```python
except Exception as e:
    if "Authentication failed" in str(e):
        print(f"âœ— {e}")
        print("Check:")
        print("  - Tenant ID correct? (Azure AD → Properties)")
        print("  - Client ID correct? (App registration → Overview)")
        print("  - Permissions granted? (App registration → API Permissions)")
        print("  - Admin consent? (API Permissions → Grant admin consent)")
        exit(1)
```

### SharePoint Access Errors

```python
except Exception as e:
    if "Access denied" in str(e):
        print(f"âœ— {e}")
        print("Fix:")
        print("  1. Go to SharePoint Admin Center")
        print("  2. Go to Share Data Access")
        print("  3. Find your RAG app")
        print("  4. Grant access to the site")
        exit(1)
```

### Network/Timeout Errors (Local Mode)

```python
except requests.Timeout:
    print("âœ— Download timeout. Possible causes:")
    print("  - Network issue")
    print("  - Large files")
    print("  - SharePoint throttling")
    print("\nRetry or:")
    print("  - Split documents into smaller library")
    print("  - Use professional mode instead")
    exit(1)
```

---

## Integration with Onboarding

When user has SharePoint in `rag-onboarding.agent.md`:

```python
# In rag-onboarding agent Phase 2 (Interview):
if ask_user("Do you have SharePoint documents?") == "Yes":
    print("\nGreat! We'll handle SharePoint for you.")
    mode = ask_user("Preferred mode?", choices=["Professional", "Local"])
    
    # Later, in Phase 5 (Indexing):
    call_agent("rag-sharepoint-setup", {
        "mode": mode.lower(),
        # User confirms manually or we auto-prompt
    })
```

---

## Success Criteria

✅ Agent completes successfully when:
- [ ] User authenticated (tokens obtained)
- [ ] SharePoint site resolved (drive ID found)
- [ ] Documents discovered (at least 1 item)
- [ ] Mode configured (professional OR local mode complete)
- [ ] Configuration saved to scripts/sharepoint-config.json
- [ ] .env updated (if local mode)
- [ ] (Local only) Documents indexed or user shown how to index
- [ ] User has clear next steps


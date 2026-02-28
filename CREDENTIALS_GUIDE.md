# 🔐 Credentials Setup - Visual Guide

## Where to Get Each Credential and Where to Put It

This guide shows you **exactly where** to find your credentials and **exactly where** to put them.

---

## 📍 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     YOUR COMPUTER                            │
│                                                              │
│  /private/tmp/devops-fastapi-project/                       │
│                                                              │
│  Files to Update:                                           │
│  1. .github/workflows/ci-cd.yml (line 11)                   │
│  2. kubernetes/test/app-deployment.yaml (line 25)           │
│  3. kubernetes/prod/app-deployment.yaml (line 26)           │
│                                                              │
└──────────────────┬───────────────────────────────────────────┘
                   │
                   │ git push
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     GITHUB.COM                               │
│                                                              │
│  Your Repository: YOUR-USERNAME/devops-fastapi-project      │
│                                                              │
│  Settings → Secrets and Variables → Actions                 │
│                                                              │
│  ADD THESE 4 SECRETS:                                       │
│  ┌────────────────────────────────────────┐                │
│  │ DOCKER_USERNAME     → Get from Docker  │                │
│  │ DOCKER_PASSWORD     → Get from Docker  │                │
│  │ AWS_ACCESS_KEY_ID   → Get from AWS     │                │
│  │ AWS_SECRET_ACCESS_KEY → Get from AWS   │                │
│  └────────────────────────────────────────┘                │
│                                                              │
└───────┬──────────────────────────┬──────────────────────────┘
        │                          │
        │ Uses secrets to          │ Uses secrets to
        │ push images              │ deploy
        ▼                          ▼
┌──────────────────┐      ┌──────────────────┐
│  DOCKER HUB      │      │   AWS EKS        │
│                  │      │                  │
│  Stores your     │      │  Runs your       │
│  Docker images   │      │  application     │
└──────────────────┘      └──────────────────┘
```

---

## 🐳 1. DOCKER HUB CREDENTIALS

### Where to Get Them:

#### Step-by-Step:

**1.1. Go to Docker Hub:**
```
🌐 https://hub.docker.com
```

**1.2. Sign Up / Log In:**
- Click "Sign Up" if new
- Or "Sign In" if you have account

**1.3. Find Your Username:**
```
Look at top-right corner: 
👤 YOUR-USERNAME
```
**Write it down: _________________**

**1.4. Create Access Token:**
```
Click: YOUR-USERNAME (top-right)
→ Account Settings
→ Security (left sidebar)
→ New Access Token
```

Fill in:
- Description: `GitHub Actions`
- Permissions: ✅ Read, Write, Delete
- Click "Generate"

**Copy the token immediately!**

**Write it down: _________________**

### Where to Put Them:

#### In GitHub:
```
1. Go to: github.com/YOUR-USERNAME/devops-fastapi-project
2. Click: Settings → Secrets and variables → Actions
3. Click: "New repository secret"

Secret #1:
Name:  DOCKER_USERNAME
Value: (paste your Docker Hub username)

Secret #2:
Name:  DOCKER_PASSWORD  
Value: (paste your Docker Hub token)
```

#### In Your Code:
```
File: .github/workflows/ci-cd.yml
Line: 11

BEFORE:
DOCKER_IMAGE: your-dockerhub-username/itemsapi

AFTER:
DOCKER_IMAGE: johnsmith/itemsapi  ← Replace with YOUR username
```

```
File: kubernetes/test/app-deployment.yaml
Line: 25

BEFORE:
image: your-dockerhub-username/itemsapi:latest

AFTER:
image: johnsmith/itemsapi:latest  ← Replace with YOUR username
```

```
File: kubernetes/prod/app-deployment.yaml
Line: 26

BEFORE:
image: your-dockerhub-username/itemsapi:latest

AFTER:
image: johnsmith/itemsapi:latest  ← Replace with YOUR username
```

---

## ☁️ 2. AWS CREDENTIALS

### Where to Get Them:

#### Step-by-Step:

**2.1. Go to AWS Console:**
```
🌐 https://console.aws.amazon.com
```

**2.2. Log In:**
- Use your AWS account credentials

**2.3. Search for IAM:**
```
Top search bar: Type "IAM" → Click IAM
```

**2.4. Create User:**
```
Left sidebar: Click "Users"
→ Click "Create user"
→ Username: github-actions-deployer
→ Click "Next"
```

**2.5. Add Permissions:**
```
Select: "Attach policies directly"
Search and check: AdministratorAccess
(or more specific EKS policies)
→ Click "Next"
→ Click "Create user"
```

**2.6. Create Access Keys:**
```
Click on the user: github-actions-deployer
→ "Security credentials" tab
→ Scroll to "Access keys"
→ Click "Create access key"
→ Select "Command Line Interface (CLI)"
→ Check confirmation box
→ Click "Next"
→ Click "Create access key"
```

**You'll see TWO things:**

```
Access key ID:         AKIA2BCD3EFG4HIJ5KLM
Secret access key:     wJal/abcdefghijklmnopqrstuvwxyz123456789
```

**Write them down:**
- Access Key ID: _________________
- Secret Access Key: _________________

**⚠️ NEVER SHARE THESE! NEVER COMMIT TO GIT!**

### Where to Put Them:

#### In GitHub:
```
1. Go to: github.com/YOUR-USERNAME/devops-fastapi-project
2. Click: Settings → Secrets and variables → Actions
3. Click: "New repository secret"

Secret #3:
Name:  AWS_ACCESS_KEY_ID
Value: (paste your AWS Access Key ID)

Secret #4:
Name:  AWS_SECRET_ACCESS_KEY
Value: (paste your AWS Secret Access Key)
```

#### For Local AWS CLI:
```
Terminal command:
$ aws configure

Prompts:
AWS Access Key ID: (paste your Access Key ID)
AWS Secret Access Key: (paste your Secret Access Key)
Default region name: us-east-1
Default output format: json
```

---

## 🐙 3. GITHUB PERSONAL ACCESS TOKEN

### Where to Get It:

#### Step-by-Step:

**3.1. Go to GitHub Settings:**
```
Click your profile picture (top-right)
→ Settings
```

**3.2. Navigate to Developer Settings:**
```
Scroll down left sidebar
→ Click "Developer settings" (very bottom)
```

**3.3. Create Token:**
```
→ Personal access tokens
→ Tokens (classic)
→ Generate new token
→ Generate new token (classic)
```

**3.4. Configure Token:**
```
Note: DevOps Project Token
Expiration: 90 days (or your choice)

Select scopes:
✅ repo (all sub-items)
✅ workflow
✅ write:packages

→ Click "Generate token"
```

**Copy the token immediately! (Starts with ghp_)**

**Write it down: _________________**

### Where to Use It:

```
When you run: git push origin main

If prompted:
Username: YOUR-GITHUB-USERNAME
Password: (paste your token here, NOT your GitHub password!)
```

---

## 📋 SUMMARY CHECKLIST

### Credentials You Need:

```
[ ] Docker Hub Username:     _________________
[ ] Docker Hub Token:        _________________
[ ] AWS Access Key ID:       _________________
[ ] AWS Secret Access Key:   _________________
[ ] GitHub Token (for push): _________________
```

### Where to Put Them:

```
IN GITHUB (Settings → Secrets):
[ ] DOCKER_USERNAME
[ ] DOCKER_PASSWORD
[ ] AWS_ACCESS_KEY_ID
[ ] AWS_SECRET_ACCESS_KEY

IN YOUR CODE FILES:
[ ] .github/workflows/ci-cd.yml (line 11)
[ ] kubernetes/test/app-deployment.yaml (line 25)
[ ] kubernetes/prod/app-deployment.yaml (line 26)

FOR LOCAL USE:
[ ] git push (uses GitHub token as password)
[ ] aws configure (uses AWS keys)
```

---

## 🎯 VISUAL: Where Each Secret Goes

```
┌─────────────────────────────────────────────────────────┐
│           GITHUB REPOSITORY SECRETS                      │
│  (Settings → Secrets and variables → Actions)           │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  Secret Name              Source               │    │
│  ├────────────────────────────────────────────────┤    │
│  │  DOCKER_USERNAME    ←  Docker Hub Username    │    │
│  │  DOCKER_PASSWORD    ←  Docker Hub Token       │    │
│  │  AWS_ACCESS_KEY_ID  ←  AWS IAM User          │    │
│  │  AWS_SECRET_ACCESS_KEY ← AWS IAM User         │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  These are used by GitHub Actions to:                   │
│  • Push images to Docker Hub                            │
│  • Deploy to AWS                                        │
└─────────────────────────────────────────────────────────┘
```

---

## 🔒 SECURITY BEST PRACTICES

### ✅ DO:
- Store secrets in GitHub Secrets (encrypted)
- Use access tokens instead of passwords
- Rotate tokens regularly (every 90 days)
- Give minimum required permissions
- Delete tokens you're not using

### ❌ DON'T:
- Commit secrets to git
- Share secrets publicly
- Use your actual password
- Give full admin access if not needed
- Leave old tokens active

---

## 🆘 TROUBLESHOOTING

### "Invalid credentials" in GitHub Actions

**Check:**
1. Go to GitHub → Settings → Secrets
2. Verify all 4 secrets are added
3. No typos in secret names (exact match required)
4. Tokens are not expired

**Fix:**
- Re-create the token
- Update the secret in GitHub

### "permission denied" when pushing to Docker Hub

**Check:**
1. Docker Hub token has "Read, Write, Delete" permissions
2. DOCKER_USERNAME is your actual username (not email)

**Fix:**
- Create new access token with correct permissions
- Update DOCKER_PASSWORD secret in GitHub

### "The security token included in the request is invalid" (AWS)

**Check:**
1. AWS Access Key ID starts with "AKIA"
2. Both Access Key ID and Secret are correct
3. IAM user has required permissions

**Fix:**
- Create new access key in AWS
- Update both AWS secrets in GitHub

---

## 📸 SCREENSHOTS WOULD BE HERE

If this were a PDF, you'd see screenshots showing:
1. Docker Hub → Security → New Access Token screen
2. AWS Console → IAM → Create User screen
3. GitHub → Settings → Secrets screen
4. VS Code showing the files to edit

**For now, follow the text instructions above carefully!**

---

## ✅ VERIFICATION

### After Setting Everything Up:

**1. Check GitHub Secrets:**
```
Go to: github.com/YOUR-USERNAME/devops-fastapi-project/settings/secrets/actions

You should see:
✅ DOCKER_USERNAME
✅ DOCKER_PASSWORD
✅ AWS_ACCESS_KEY_ID
✅ AWS_SECRET_ACCESS_KEY
```

**2. Check Code Files:**
```
Search for "your-dockerhub-username" in:
- .github/workflows/ci-cd.yml
- kubernetes/test/app-deployment.yaml
- kubernetes/prod/app-deployment.yaml

Replace ALL occurrences with YOUR actual Docker Hub username
```

**3. Test Locally:**
```bash
# Should work without any credentials
docker-compose up -d
curl http://localhost:8000/health
```

**4. Test CI/CD:**
```bash
# Push to trigger GitHub Actions
git add .
git commit -m "Test CI/CD"
git push origin develop

# Watch at: github.com/YOUR-USERNAME/devops-fastapi-project/actions
```

---

**If all 4 checks pass, you're ready to go! 🚀**

---

## 📞 STILL STUCK?

### Common Questions:

**Q: Where is my Docker Hub username?**
**A:** Log in to hub.docker.com, it's in the top-right corner

**Q: I lost my Docker token, what do I do?**
**A:** Create a new one, you can have multiple tokens

**Q: Do I need AWS if I just want to test locally?**
**A:** No! You can skip AWS and just use Docker locally

**Q: Can I use a real GitHub password instead of token?**
**A:** No, GitHub requires Personal Access Tokens for security

**Q: How do I know if secrets are working?**
**A:** Push code and watch GitHub Actions - if it succeeds, they work!

---

**Remember: NEVER commit secrets to git!** 🔒

**All sensitive data goes in GitHub Secrets!** 🔐

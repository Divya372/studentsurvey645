# 645 - Assignment 1: Static Website with AWS Deployment

**Name:** Divya Soni 
**Course:** 645  
**Assignment:** Assignment 1  

---

## Project Overview

This project consists of a personal homepage with a student survey form, deployed on AWS using both S3 static website hosting and EC2 instance.

### Files Included

| File | Description |
|------|-------------|
| `index.html` | Main homepage with Bootstrap styling |
| `survey.html` | Student Survey form with validation |
| `error.html` | Custom error page for 404 errors |
| `README.md` | This documentation file |

---

## Live URLs (Update after deployment)

- **S3 Static Website:** `http://div-645-assignment1.s3-website.us-east-2.amazonaws.com`
- **EC2 Instance:** `http://3.138.154.222` 

---

## Part 1: AWS S3 Static Website Hosting

### Step 1: Create an S3 Bucket

1. Log in to the **AWS Management Console**
2. Navigate to **S3** service (search "S3" in the search bar)
3. Click **"Create bucket"**
4. Configure the bucket:
   - **Bucket name:** Choose a globally unique name (e.g., `your-name-645-assignment1`)
   - **AWS Region:** Select your preferred region (e.g., `us-east-1`)
   - **Object Ownership:** Select "ACLs enabled" and "Bucket owner preferred"
   - **Block Public Access settings:** 
     - **UNCHECK** "Block all public access"
     - Acknowledge the warning checkbox
   - Leave other settings as default
5. Click **"Create bucket"**

### Step 2: Enable Static Website Hosting

1. Click on your newly created bucket
2. Go to the **"Properties"** tab
3. Scroll down to **"Static website hosting"**
4. Click **"Edit"**
5. Configure:
   - **Static website hosting:** Enable
   - **Hosting type:** Host a static website
   - **Index document:** `index.html`
   - **Error document:** `error.html`
6. Click **"Save changes"**
7. Note the **Bucket website endpoint** URL (you'll need this later)

### Step 3: Configure Bucket Policy for Public Access

1. Go to the **"Permissions"** tab
2. Scroll to **"Bucket policy"**
3. Click **"Edit"**
4. Paste the following policy (replace `YOUR-BUCKET-NAME` with your actual bucket name):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

5. Click **"Save changes"**

### Step 4: Upload Website Files

1. Go to the **"Objects"** tab
2. Click **"Upload"**
3. Click **"Add files"**
4. Select all your website files:
   - `index.html`
   - `survey.html`
   - `error.html`
5. Click **"Upload"**
6. Wait for upload to complete, then click **"Close"**

### Step 5: Test Your S3 Website

1. Go back to **"Properties"** tab
2. Scroll to **"Static website hosting"**
3. Click the **Bucket website endpoint** URL
4. Your website should now be live!

---

## Part 2: AWS EC2 Instance Deployment

### Step 1: Launch an EC2 Instance

1. Navigate to **EC2** service in AWS Console
2. Click **"Launch instance"**
3. Configure the instance:

   **Name and tags:**
   - Name: `645-Assignment1-WebServer`

   **Application and OS Images:**
   - Select **Amazon Linux 2023** or **Ubuntu Server 22.04 LTS** (Free tier eligible)

   **Instance type:**
   - Select **t2.micro** (Free tier eligible)

   **Key pair:**
   - Click **"Create new key pair"**
   - Key pair name: `645-assignment-key`
   - Key pair type: RSA
   - Private key format: `.pem` (for Mac/Linux) or `.ppk` (for Windows/PuTTY)
   - Click **"Create key pair"** (the key file will download automatically)
   - **IMPORTANT:** Save this key file securely - you cannot download it again!

   **Network settings:**
   - Click **"Edit"**
   - Allow SSH traffic from: My IP (or Anywhere if needed)
   - **Check** "Allow HTTP traffic from the internet"
   - **Check** "Allow HTTPS traffic from the internet"

   **Storage:**
   - Keep default (8 GiB gp3)

4. Click **"Launch instance"**
5. Wait for the instance to start (Status: Running)

### Step 2: Connect to Your EC2 Instance

#### For Windows (using PuTTY):

1. Download and install [PuTTY](https://www.putty.org/)
2. If you downloaded a `.pem` file, convert it to `.ppk`:
   - Open **PuTTYgen**
   - Click **"Load"** and select your `.pem` file
   - Click **"Save private key"** to save as `.ppk`
3. Open **PuTTY**
4. In Host Name, enter: `ec2-user@YOUR-EC2-PUBLIC-IP`
   - For Ubuntu: use `ubuntu@YOUR-EC2-PUBLIC-IP`
5. Go to **Connection > SSH > Auth > Credentials**
6. Browse and select your `.ppk` file
7. Click **"Open"** to connect

#### For Mac/Linux (using Terminal):

```bash
# Set permissions on key file
chmod 400 645-assignment-key.pem

# Connect to EC2 (Amazon Linux)
ssh -i "645-assignment-key.pem" ec2-user@YOUR-EC2-PUBLIC-IP

# Or for Ubuntu
ssh -i "645-assignment-key.pem" ubuntu@YOUR-EC2-PUBLIC-IP
```

### Step 3: Install Web Server (Apache)

Once connected to your EC2 instance, run the following commands:

#### For Amazon Linux 2023:

```bash
# Update the system
sudo yum update -y

# Install Apache web server
sudo yum install -y httpd

# Start Apache
sudo systemctl start httpd

# Enable Apache to start on boot
sudo systemctl enable httpd

# Verify Apache is running
sudo systemctl status httpd
```

#### For Ubuntu:

```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install Apache web server
sudo apt install -y apache2

# Start Apache
sudo systemctl start apache2

# Enable Apache to start on boot
sudo systemctl enable apache2

# Verify Apache is running
sudo systemctl status apache2
```

### Step 4: Upload Website Files to EC2

#### Option A: Using SCP (Secure Copy) from your local machine

Open a new terminal/command prompt on your local computer:

```bash
# For Amazon Linux (files go to /var/www/html/)
scp -i "645-assignment-key.pem" index.html survey.html error.html ec2-user@YOUR-EC2-PUBLIC-IP:/tmp/

# Then on EC2, move files to web directory:
sudo mv /tmp/*.html /var/www/html/
```

#### Option B: Using SFTP client (FileZilla)

1. Download and install [FileZilla](https://filezilla-project.org/)
2. Go to **File > Site Manager**
3. Click **"New Site"**
4. Configure:
   - Protocol: SFTP
   - Host: YOUR-EC2-PUBLIC-IP
   - Port: 22
   - Logon Type: Key file
   - User: `ec2-user` (or `ubuntu` for Ubuntu)
   - Key file: Browse to your `.pem` or `.ppk` file
5. Click **"Connect"**
6. Navigate to `/var/www/html/` on the remote side
7. Upload your files (you may need to upload to `/tmp/` first, then move using SSH)

#### Option C: Create files directly on EC2

Connect via SSH and create files:

```bash
# Navigate to web directory
cd /var/www/html/

# Create and edit files using nano
sudo nano index.html
# Paste your index.html content, then Ctrl+X, Y, Enter to save

sudo nano survey.html
# Paste your survey.html content, then Ctrl+X, Y, Enter to save

sudo nano error.html
# Paste your error.html content, then Ctrl+X, Y, Enter to save
```

### Step 5: Set Proper Permissions

```bash
# Set ownership
sudo chown -R apache:apache /var/www/html/    # For Amazon Linux
# OR
sudo chown -R www-data:www-data /var/www/html/    # For Ubuntu

# Set permissions
sudo chmod -R 755 /var/www/html/
```

### Step 6: Test Your EC2 Website

1. Go back to AWS EC2 Console
2. Select your instance
3. Copy the **Public IPv4 address** or **Public IPv4 DNS**
4. Open a web browser and navigate to: `http://YOUR-EC2-PUBLIC-IP`
5. Your website should now be live!

---

## Troubleshooting

### S3 Issues

| Problem | Solution |
|---------|----------|
| 403 Forbidden | Check bucket policy and public access settings |
| 404 Not Found | Verify index.html exists and static hosting is enabled |
| Files not accessible | Ensure "Block all public access" is unchecked |

### EC2 Issues

| Problem | Solution |
|---------|----------|
| Cannot connect via SSH | Check Security Group allows SSH (port 22) from your IP |
| Website not loading | Check Security Group allows HTTP (port 80) |
| Permission denied | Verify file permissions (chmod 755) |
| Apache not running | Run `sudo systemctl start httpd` (or apache2) |

### Common Commands

```bash
# Check Apache status
sudo systemctl status httpd    # Amazon Linux
sudo systemctl status apache2  # Ubuntu

# Restart Apache
sudo systemctl restart httpd   # Amazon Linux
sudo systemctl restart apache2 # Ubuntu

# View Apache error logs
sudo tail -f /var/log/httpd/error_log    # Amazon Linux
sudo tail -f /var/log/apache2/error.log  # Ubuntu

# Check firewall (if applicable)
sudo firewall-cmd --list-all
```

---

## Security Reminders

1. **Never share your `.pem` key file** - Anyone with this file can access your EC2 instance
2. **Restrict SSH access** - Only allow your IP address in security groups
3. **Stop EC2 when not in use** - To avoid charges (free tier has limits)
4. **Delete resources after grading** - Remove S3 bucket and terminate EC2 to avoid ongoing charges

---

## Cost Considerations

- **S3:** First 5GB storage free, minimal request costs
- **EC2 t2.micro:** 750 hours/month free for 12 months (AWS Free Tier)
- **Data Transfer:** First 100GB/month free

**Remember to clean up resources after the assignment is graded to avoid unexpected charges!**

---

## Resources

- [AWS S3 Static Website Hosting Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [AWS EC2 Getting Started Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EC2_GetStarted.html)
- [Bootstrap Documentation](https://getbootstrap.com/docs/5.3/)
- [W3Schools HTML Tutorial](https://www.w3schools.com/html/)

---

## Submission Checklist

- [ ] Homepage (index.html) with image and paragraph
- [ ] Student Survey form (survey.html) with all required fields
- [ ] Error page (error.html)
- [ ] Website deployed on S3 with working URL
- [ ] Website deployed on EC2 with working URL
- [ ] README file with deployment instructions
- [ ] All files zipped and submitted to Canvas
- [ ] URLs included in README
- [ ] Name on all source files

---

**End of README**

#!/bin/bash
#set -e  # Exit immediately on error
#set -o pipefail

### --- USER CONFIGURATION SECTION ---
#AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
#AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
AWS_REGION="ap-south-1"
S3_BUCKET_NAME="bikram-kops-state-$(date +%s)"
CLUSTER_NAME="bikram.k8s.local"
ZONES="ap-south-1a"
CONTROL_PLANE_SIZE="t2.large"
NODE_SIZE="t2.medium"
NODE_COUNT="2"
### ----------------------------------

echo "[INFO] Installing dependencies..."
sudo apt update -y
sudo apt install -y awscli curl wget unzip

#echo "[INFO] Configuring AWS CLI..."
#aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
#aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
#aws configure set region $AWS_REGION
#aws configure set output json

echo "[INFO] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "[INFO] Installing kops..."
wget https://github.com/kubernetes/kops/releases/download/v1.33.0/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

echo "[INFO] Creating S3 bucket: $S3_BUCKET_NAME..."
aws s3api create-bucket \
  --bucket $S3_BUCKET_NAME \
  --region $AWS_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_REGION

aws s3api put-bucket-versioning \
  --bucket $S3_BUCKET_NAME \
  --region $AWS_REGION \
  --versioning-configuration Status=Enabled

export KOPS_STATE_STORE="s3://$S3_BUCKET_NAME"
echo "export KOPS_STATE_STORE=s3://$S3_BUCKET_NAME" >> ~/.bashrc
source ~/.bashrc

echo "[INFO] Creating Kops cluster config..."
kops create cluster \
  --name=$CLUSTER_NAME \
  --state=$KOPS_STATE_STORE \
  --zones=$ZONES \
  --control-plane-count=1 \
  --control-plane-size=$CONTROL_PLANE_SIZE \
  --node-count=$NODE_COUNT \
  --node-size=$NODE_SIZE \
  --networking=calico \
  --yes

echo "[INFO] Cluster creation initiated. It can take 10–15 minutes."
echo "Once ready, validate using:"
echo "  kops validate cluster --state=$KOPS_STATE_STORE"
echo "Check nodes with:"
echo "  kubectl get nodes"


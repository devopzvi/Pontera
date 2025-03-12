## 1️. Assume We Have Already Created an IAM Role  

### IAM Role Policy:  
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:us-east-2:123456789012:secret:my-secret-*"
    }
  ]
}
```

With Trust Relationship:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/xxxxxxxxxxxx"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.us-east-2.amazonaws.com/id/xxxxxxxxxxxx:sub": "system:serviceaccount:default:aws-cli-sa"
        }
      }
    }
  ]
}
```

## 2. manifest-minikube.yaml:
- Made for local testing of the manifest on minikube
- Deployed a secret manifest in advance.
- Removed eks annotation as Minikube, which doesn’t support IRSA.
- Replaced the AWS CLI command with a shell script that reads a secret from a file.
- The command runs an infinite loop that prints the secret value every 5 seconds.
- Mounted a Kubernetes Secret as a file inside the container so the script can read it. I deliberately did not use it as a secretKeyRef.


---
title: "What Two Unexpected AWS Billing Alerts Taught Me"
date: 2026-04-10
description: "Two unexpected billing alerts from AWS, and what they forced me to learn."
---

Recently, I built a product called PrepIt from scratch and decided to deploy it on AWS. To learn how, I took an online course and did some searching on GPT. This is what it told me:

1. Use the root user that gets created when you sign up on the AWS console.
2. Create an IAM user. Always access the console using the IAM user.
3. Set a billing alert.

Following instructions, I set a billing alert at $5. In my head, I was on the AWS free tier (valid for 6 months), so why would I even need a billing alert?

## Launching the EC2 Instance

1. Selected Ubuntu 22.04 as the base image.
2. Decided how much RAM and disk space I needed.
3. I had a multi-container Docker Compose file, since the product used Weaviate as a vector database. Weaviate requires more memory.
4. Found out that the free tier only gives you 1GB RAM. My setup needed a bare minimum of 2GB to run without crashing.
5. To meet this requirement, I selected t3.small. t3.micro is free tier eligible, but t3.small is not. I had to move to a paid instance.
6. After launching the EC2 instance, I allocated an Elastic IP and associated it with the instance.
7. Then mapped the Elastic IP to the domain prepit.mridulabs.dev.

The whole setup worked. I SSH'd into the server, did a `git pull`, and ran the Docker Compose command to bring the containers up. **Voila, my site was up and running. I was overjoyed.**

The joy of building something from scratch was so great that I wanted to keep it live. Access was restricted to allowed users, so I shared the URL with a few friends to try it out. Barely 2 of them did. No real traffic, but I convinced myself to keep it running anyway.

On the 5th day, I woke up to the first alert email from AWS:

*"AWS Budgets: Monthly Learning Budget has exceeded your alert threshold"*

- Budgeted amount: $5
- Alert threshold: >$4.25
- Actual amount: $4.28

## What Was I Getting Charged For?

1. EC2 Instance (t3.small) running 24/7
2. Elastic IP

The instance had been created in Sydney by default. Sydney has higher rates than Mumbai, so the EC2 and Elastic IP charges were higher than they needed to be.

## What I Fixed?

1. **Stopped** the running EC2 instance.
2. Learned that Elastic IPs are chargeable. So I **disassociated** the Elastic IP from the instance.
3. Kept the volume, since the vector database still had embeddings and PostgreSQL had some data.

I felt confident, no more alerts. I also assumed the $5 budget was already crossed, so I set a new alert at $8.

But that assumption was wrong. The first email had triggered at $4.28, which crossed the alert threshold of $4.25, not the budget limit of $5. The $5 limit hadn't been crossed yet.

Two days later, another email.

*"AWS Budgets: Monthly Learning Budget has exceeded your alert threshold"*

- Budgeted amount: $5
- Alert threshold: >$5
- Actual amount: $5.04

## What I Learned?

1. **Stopping an instance is not the same as terminating it.** A stopped instance no longer runs, but associated resources like Elastic IPs continue to be billed.
2. **Disassociating an Elastic IP is not enough.** Disassociating just means it's no longer linked to a running instance, but AWS still charges for it. You need to release it to give it back to AWS and stop being charged. I had disassociated it, but never released it.
3. **Region pricing matters for paid instances.** Since t3.small is not free tier eligible, the region affected my bill. Sydney is more expensive than Mumbai. Pick the region closest to your users. It's cheaper and faster.

## What I Did to Stop the Billing?

1. Terminated the instance. Stopping is not enough.
2. Released the Elastic IP. Disassociating is not enough.
3. Deleted the volume. It was within the free tier so not costing anything, but deleted it since the project was no longer running.

No more alert emails. Spending roughly $6 taught me something that no course could have. Some lessons only land when real money is on the line.

I could migrate to a different provider. But for now, I've sunsetted the product.

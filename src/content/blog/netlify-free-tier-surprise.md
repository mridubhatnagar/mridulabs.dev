---
title: "I Thought Netlify Was Free, Until My Site Was Taken Down"
date: 2026-04-10
description: "Netlify took my site down. Here is what happened."
tags: ["Netlify", "Deployment", "Cloud Cost"]
---

<!-- Draft your content below. I'll refine it once you share. -->
Several years ago I had deployed my first portfolio website on Netlify. 
I didn't maintain it and eventually decided to let go. 

Back then, I got to know from friends that Netlify is a good place to deploy static websites like a portfolio.
Years have passed, but in my head still Netlify is free.

I went ahead, deployed the website on Netlify because Netlify was more familiar to me
than using Vercel or anything. And, mapped netlify site url to my custom domain. 

Then, I linked Netlify to the portfolio repo on GitHub. Ensuring it auto deploys. Because, why not?
Auto-deployment is cool. 

Once the site was live, I started making small edits in the content across
the website. git add , commit , push. All linked from master branch of my repo. 

Now, everytime I push code to the remote repo. The push is triggering auto-build on Netlify. The cool looking setup is eating credits. 
I knew my setup. But, my mental model still said. Netlify is free. 

Yesterday, evening. One last build got triggered. And, boom! Your site is down, you don't have enough credits.
I checked the billing and usage dashboard. **22 Deploys, consumed 330 credits.**

Each production deployment costs 15 credits. With 300 free credits, you only get 20 deployments per month. 22 pushes later, I was out.

I had 2 choices. Again migrate and do the setup. Or pay the money. 
I had no time to again migrate and setup. I ended up paying $9 to Netlify. 

$9/month gives you 1000 credits. And, maybe the cool looking auto-build trigger needs to be turned off.

## What I Learned?

1. **Check the pricing model before you jump onto the developer console.** Services that were free years ago may no longer be. What your friends told you in 2019 may not hold true today.
2. **Netlify gave no warning.** No email, no alert before the site went down. If you are on the free tier, set up usage alerts yourself. Don't assume the platform will tell you before it pulls the plug.
3. **Auto-build on every push burns through credits fast.** 22 pushes consumed 330 credits. If you are the only developer and your changes are frequent, consider triggering builds manually or only on specific branches.


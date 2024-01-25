---
title: "AI workflow support"
owner:
- https://github.com/orgs/giantswarm/teams/team-horizon
confidentiality: public
---

## Why do we need this?

We have seen some of the questions from our customers are replied multiple times. At the same time there are different areas in the company and none now knows everything across teams. Ideally to solve that we put everything in docs so we can profit in support as main source of information. But the problem comes when we need to get the exact question replied for the huge amounts of content our docs have. The goal with the `AI support workflow` is to solve this pain, allowing our support colleagues ask question to a GPT (called `Inkeep`) and get a decent correct answer.

## How this works?

We have a workflow that could look like

![AI workflow schema](ai-workflow-00.png)

Here we see there is a bot, called `@Ask Inkeep`, which is [automatically called every new support thread by a dummy reply bot](https://github.com/giantswarm/slack-replier). Inkeep bot will use Open AI technology to query a custom GPT for an answer that has been trained with our official documentation.

THe AI bot will send a request to trained model and will reply in the same thread. Also the bots ask for feedback on the response. This is important to make the responses more accurate. In case the response is good, it can be used to reply the customer directly (potentially one day we can put this in front on the customer). In case it is not, then as usual we ask the owner team to give us a correct answer. It could be there is a back and forth till we mark the thread as done.

![AI workflow Inkeep](ai-workflow-01.png)

At this point, when we have clarified the thread and satisfied the customer, we could run [FAIQ](https://github.com/giantswarm/faiq) to get a good summary of what we have been done in the support request (adding `:support-recipe` icon). It will go through the thread and output a good summary, only taking the content from humans, and asking Open AI for a good summary following some format. Voila, we have markdown response with what has been done.

![AI workflow summary](ai-workflow-02.png)

We could end here but to close the circle ideally we put back the learnt lesson into our docs so AI bot will have a better answer next time. In order to do that we have created a [little bot](https://github.com/giantswarm/pr-generator/) that listen to an icon (`pr-github-open`) and push the message (apply it to the markdown summary please) to our docs automatically. After the team in question reviews the PR we can merge and Inkeep will scrape it and include in the LLM database.

![AI workflow PR](ai-workflow-03.png)

## Further links

- [Inkeep Official docs](https://docs.inkeep.com/overview/getting-started)
- [Slack Replier repo](https://github.com/giantswarm/slack-replier)
- [FAIQ repo](https://github.com/giantswarm/faiq)
- [PR generator repo](https://github.com/giantswarm/pr-generator)

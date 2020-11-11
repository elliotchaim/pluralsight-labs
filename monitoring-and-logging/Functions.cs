using System;
using System.Threading;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace Pluralsight
{
    public class Functions
    {
        [FunctionName(nameof(HealthyFunction))]
        public void HealthyFunction([TimerTrigger("*/1 * * * * *")] TimerInfo myTimer,
            ILogger log, CancellationToken cancellationToken)
        {
            log.LogInformation($"[{nameof(HealthyFunction)}]: Triggered.");
            log.LogInformation($"[{nameof(HealthyFunction)}]: Complete.");
        }

        [FunctionName(nameof(BrokenFunction))]
        public void BrokenFunction([TimerTrigger("*/5 * * * * *")] TimerInfo myTimer,
            ILogger log, CancellationToken cancellationToken)
        {
            log.LogInformation($"[{nameof(BrokenFunction)}]: Triggered.");
            throw new Exception("Something is broken!");
        }

        [FunctionName(nameof(HealthChecks))]
        public IActionResult HealthChecks([HttpTrigger(AuthorizationLevel.Anonymous, "head", "get", Route = "health")] HttpRequest request,
            ILogger log, CancellationToken cancellationToken)
        {
            log.LogInformation($"[{nameof(HealthyFunction)}]: Triggered.");
            log.LogInformation($"[{nameof(HealthyFunction)}]: Complete.");
            return new OkResult();
        }
    }
}

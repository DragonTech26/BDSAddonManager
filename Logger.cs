
namespace AddonManager
{
    public static class Logger
    {
        private static List<string> logs = new List<string>();

        public static void Log(string message, string level = "INFO")
        {
            logs.Add($"[{level}] {message}");
        }
        public static List<string> GetLogs()
        {
            return logs;
        }
    }
}

// Logger.Log("Message here!", "INFO/WARN/ERROR")
// The level is optional, it will default to INFO.
// Colors are Cyan, Yellow, and Red. Unknown is white.

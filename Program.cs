namespace AddonManager
{
    internal static class Program
    {
        //Program info
        public static string version = "v1.4.1";
        public static string title = "BDS Addon Manager";

        //Settings options
        public static bool hideDefaultPacks = true;
        public static bool hideConsoleTab = true;
        public static bool disableStringCleaner = false;

        [STAThread]
        static void Main()
        {
            ApplicationConfiguration.Initialize();
            Application.Run(new MainForm());
        }
    }
}
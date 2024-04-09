namespace AddonManager
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        public static string version = "v1.4.1";
        public static string title = "BDS Addon Manager";

        public static bool hideDefaultPacks = true;
        public static bool hideConsoleTab = true;
        public static bool disableStringCleaner = false;

        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            Application.Run(new MainForm());
        }
    }
}
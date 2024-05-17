namespace AddonManager
{
    internal static class Program
    {
        //Program info
        public static string version = "v1.4.2";
        public static string title = "BDS Addon Manager";

        [STAThread]
        static void Main()
        {
            ApplicationConfiguration.Initialize();
            Application.Run(new MainForm());
        }
    }
}
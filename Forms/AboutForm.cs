
namespace AddonManager.Forms
{
    public partial class AboutForm : Form
    {
        public AboutForm()
        {
            InitializeComponent();
            this.Text = "ABOUT"; //Header title
            aboutLabel.Text = about;
        }
        string about =
    @"This tool is designed to streamline the management of addons for self-hosted Minecraft: Bedrock Edition servers.

⚠️ Modifying an existing world may lead to unexpected results. It is advised to create a backup before proceeding.

Instructions:
1. On the Directory screen, locate the root world folder containing 'level.dat', as well as the root resource and behavior pack folders.
2. Click the 'Validate' button to verify world paths and begin the loading process.
3. Select the desired pack type from the sidebar and use the mouse to select packs. Once selected, use the buttons to arrange them. Packs listed higher in the list will have precedence.
4. Once you have made the changes, press the 'Save' button to apply them to the world.

Adding New Packs:
To include a new pack, place the file into the appropriate directory and restart the program. The new pack will appear in the inactive list.

Credits:
Various icons used in this project are sourced from svgrepo.com. These icons are available under the Public Domain.

Disclaimer:
This is not an official Minecraft product, nor is it endorsed by or affiliated with Mojang or Microsoft.
";
    }
}

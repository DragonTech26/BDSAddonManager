namespace AddonManager
{
    partial class MainForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            menuPanel = new Panel();
            infoButton = new Button();
            saveButton = new Button();
            consoleButton = new Button();
            bpButton = new Button();
            rpButton = new Button();
            directoryButton = new Button();
            logoPanel = new Panel();
            logoPictureBox = new PictureBox();
            versionLabel = new Label();
            logoLabel = new Label();
            headerPanel = new Panel();
            headerLabel = new Label();
            workspacePanel = new Panel();
            menuPanel.SuspendLayout();
            logoPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)logoPictureBox).BeginInit();
            headerPanel.SuspendLayout();
            SuspendLayout();
            // 
            // menuPanel
            // 
            menuPanel.BackColor = Color.FromArgb(38, 43, 50);
            menuPanel.Controls.Add(infoButton);
            menuPanel.Controls.Add(saveButton);
            menuPanel.Controls.Add(consoleButton);
            menuPanel.Controls.Add(bpButton);
            menuPanel.Controls.Add(rpButton);
            menuPanel.Controls.Add(directoryButton);
            menuPanel.Controls.Add(logoPanel);
            menuPanel.Dock = DockStyle.Left;
            menuPanel.Location = new Point(0, 0);
            menuPanel.Name = "menuPanel";
            menuPanel.Size = new Size(220, 561);
            menuPanel.TabIndex = 0;
            // 
            // infoButton
            // 
            infoButton.Dock = DockStyle.Top;
            infoButton.FlatAppearance.BorderSize = 0;
            infoButton.FlatStyle = FlatStyle.Flat;
            infoButton.ForeColor = Color.LightGray;
            infoButton.Image = Properties.Resources.info;
            infoButton.ImageAlign = ContentAlignment.MiddleLeft;
            infoButton.Location = new Point(0, 320);
            infoButton.Name = "infoButton";
            infoButton.Padding = new Padding(12, 0, 0, 0);
            infoButton.Size = new Size(220, 60);
            infoButton.TabIndex = 6;
            infoButton.Text = "   About";
            infoButton.TextAlign = ContentAlignment.MiddleLeft;
            infoButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            infoButton.UseVisualStyleBackColor = true;
            infoButton.Click += infoButton_Click;
            // 
            // saveButton
            // 
            saveButton.Dock = DockStyle.Bottom;
            saveButton.FlatAppearance.BorderSize = 0;
            saveButton.FlatStyle = FlatStyle.Flat;
            saveButton.ForeColor = Color.LightGray;
            saveButton.Image = Properties.Resources.save;
            saveButton.ImageAlign = ContentAlignment.MiddleLeft;
            saveButton.Location = new Point(0, 501);
            saveButton.Name = "saveButton";
            saveButton.Padding = new Padding(12, 0, 0, 0);
            saveButton.Size = new Size(220, 60);
            saveButton.TabIndex = 5;
            saveButton.Text = "   Save";
            saveButton.TextAlign = ContentAlignment.MiddleLeft;
            saveButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            saveButton.UseVisualStyleBackColor = true;
            saveButton.Click += saveButton_Click;
            // 
            // consoleButton
            // 
            consoleButton.Dock = DockStyle.Top;
            consoleButton.FlatAppearance.BorderSize = 0;
            consoleButton.FlatStyle = FlatStyle.Flat;
            consoleButton.ForeColor = Color.LightGray;
            consoleButton.Image = Properties.Resources.terminal;
            consoleButton.ImageAlign = ContentAlignment.MiddleLeft;
            consoleButton.Location = new Point(0, 260);
            consoleButton.Name = "consoleButton";
            consoleButton.Padding = new Padding(12, 0, 0, 0);
            consoleButton.Size = new Size(220, 60);
            consoleButton.TabIndex = 4;
            consoleButton.Text = "   Console Logs";
            consoleButton.TextAlign = ContentAlignment.MiddleLeft;
            consoleButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            consoleButton.UseVisualStyleBackColor = true;
            consoleButton.Click += consoleButton_Click;
            // 
            // bpButton
            // 
            bpButton.Dock = DockStyle.Top;
            bpButton.FlatAppearance.BorderSize = 0;
            bpButton.FlatStyle = FlatStyle.Flat;
            bpButton.ForeColor = Color.LightGray;
            bpButton.Image = Properties.Resources.script;
            bpButton.ImageAlign = ContentAlignment.MiddleLeft;
            bpButton.Location = new Point(0, 200);
            bpButton.Name = "bpButton";
            bpButton.Padding = new Padding(12, 0, 0, 0);
            bpButton.Size = new Size(220, 60);
            bpButton.TabIndex = 3;
            bpButton.Text = "   Behavior Packs";
            bpButton.TextAlign = ContentAlignment.MiddleLeft;
            bpButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            bpButton.UseVisualStyleBackColor = true;
            bpButton.Click += bpButton_Click;
            // 
            // rpButton
            // 
            rpButton.Dock = DockStyle.Top;
            rpButton.FlatAppearance.BorderSize = 0;
            rpButton.FlatStyle = FlatStyle.Flat;
            rpButton.ForeColor = Color.LightGray;
            rpButton.Image = Properties.Resources.cube;
            rpButton.ImageAlign = ContentAlignment.MiddleLeft;
            rpButton.Location = new Point(0, 140);
            rpButton.Name = "rpButton";
            rpButton.Padding = new Padding(12, 0, 0, 0);
            rpButton.Size = new Size(220, 60);
            rpButton.TabIndex = 2;
            rpButton.Text = "   Resource Packs";
            rpButton.TextAlign = ContentAlignment.MiddleLeft;
            rpButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            rpButton.UseVisualStyleBackColor = true;
            rpButton.Click += rpButton_Click;
            // 
            // directoryButton
            // 
            directoryButton.Dock = DockStyle.Top;
            directoryButton.FlatAppearance.BorderSize = 0;
            directoryButton.FlatStyle = FlatStyle.Flat;
            directoryButton.ForeColor = Color.LightGray;
            directoryButton.Image = Properties.Resources.world;
            directoryButton.ImageAlign = ContentAlignment.MiddleLeft;
            directoryButton.Location = new Point(0, 80);
            directoryButton.Name = "directoryButton";
            directoryButton.Padding = new Padding(12, 0, 0, 0);
            directoryButton.Size = new Size(220, 60);
            directoryButton.TabIndex = 1;
            directoryButton.Text = "   World Directories";
            directoryButton.TextAlign = ContentAlignment.MiddleLeft;
            directoryButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            directoryButton.UseVisualStyleBackColor = true;
            directoryButton.Click += directoryButton_Click;
            // 
            // logoPanel
            // 
            logoPanel.BackColor = Color.FromArgb(23, 29, 37);
            logoPanel.Controls.Add(logoPictureBox);
            logoPanel.Controls.Add(versionLabel);
            logoPanel.Controls.Add(logoLabel);
            logoPanel.Dock = DockStyle.Top;
            logoPanel.Location = new Point(0, 0);
            logoPanel.Name = "logoPanel";
            logoPanel.Size = new Size(220, 80);
            logoPanel.TabIndex = 0;
            // 
            // logoPictureBox
            // 
            logoPictureBox.Image = Properties.Resources.logo;
            logoPictureBox.Location = new Point(24, 12);
            logoPictureBox.Name = "logoPictureBox";
            logoPictureBox.Size = new Size(48, 49);
            logoPictureBox.SizeMode = PictureBoxSizeMode.StretchImage;
            logoPictureBox.TabIndex = 0;
            logoPictureBox.TabStop = false;
            logoPictureBox.Click += logoPictureBox_Click;
            // 
            // versionLabel
            // 
            versionLabel.AutoSize = true;
            versionLabel.ForeColor = Color.White;
            versionLabel.Location = new Point(84, 38);
            versionLabel.Name = "versionLabel";
            versionLabel.Size = new Size(40, 16);
            versionLabel.TabIndex = 1;
            versionLabel.Text = "v0.0.0";
            // 
            // logoLabel
            // 
            logoLabel.AutoSize = true;
            logoLabel.ForeColor = Color.White;
            logoLabel.Location = new Point(84, 22);
            logoLabel.Name = "logoLabel";
            logoLabel.Size = new Size(94, 16);
            logoLabel.TabIndex = 0;
            logoLabel.Text = "Addon Manager";
            // 
            // headerPanel
            // 
            headerPanel.BackColor = Color.FromArgb(31, 56, 78);
            headerPanel.Controls.Add(headerLabel);
            headerPanel.Dock = DockStyle.Top;
            headerPanel.Location = new Point(220, 0);
            headerPanel.Name = "headerPanel";
            headerPanel.Size = new Size(764, 80);
            headerPanel.TabIndex = 1;
            // 
            // headerLabel
            // 
            headerLabel.Dock = DockStyle.Fill;
            headerLabel.Font = new Font("Segoe UI Variable Small", 16F);
            headerLabel.ForeColor = Color.White;
            headerLabel.Location = new Point(0, 0);
            headerLabel.Name = "headerLabel";
            headerLabel.Size = new Size(764, 80);
            headerLabel.TabIndex = 0;
            headerLabel.Text = "TITLE";
            headerLabel.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // workspacePanel
            // 
            workspacePanel.Dock = DockStyle.Fill;
            workspacePanel.Location = new Point(220, 80);
            workspacePanel.Name = "workspacePanel";
            workspacePanel.Size = new Size(764, 481);
            workspacePanel.TabIndex = 2;
            // 
            // MainForm
            // 
            AutoScaleDimensions = new SizeF(7F, 16F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(984, 561);
            Controls.Add(workspacePanel);
            Controls.Add(headerPanel);
            Controls.Add(menuPanel);
            Icon = (Icon)resources.GetObject("$this.Icon");
            MinimumSize = new Size(850, 500);
            Name = "MainForm";
            StartPosition = FormStartPosition.CenterScreen;
            Text = "MainForm";
            menuPanel.ResumeLayout(false);
            logoPanel.ResumeLayout(false);
            logoPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)logoPictureBox).EndInit();
            headerPanel.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private Panel menuPanel;
        private Panel logoPanel;
        private Button directoryButton;
        private Button consoleButton;
        private Button bpButton;
        private Button rpButton;
        private Button saveButton;
        private Panel headerPanel;
        private Label headerLabel;
        private Label logoLabel;
        private Panel workspacePanel;
        private PictureBox logoPictureBox;
        private Label versionLabel;
        private Button infoButton;
    }
}

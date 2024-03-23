namespace AddonManager.Forms
{
    partial class AboutForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            aboutLabel = new Label();
            SuspendLayout();
            // 
            // aboutLabel
            // 
            aboutLabel.Dock = DockStyle.Fill;
            aboutLabel.Font = new Font("Segoe UI Variable Small", 10F);
            aboutLabel.Location = new Point(0, 0);
            aboutLabel.Name = "aboutLabel";
            aboutLabel.Size = new Size(748, 442);
            aboutLabel.TabIndex = 1;
            aboutLabel.Text = "About";
            // 
            // AboutForm
            // 
            AutoScaleDimensions = new SizeF(7F, 16F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(748, 442);
            Controls.Add(aboutLabel);
            Name = "AboutForm";
            Text = "AboutForm";
            ResumeLayout(false);
        }

        #endregion
        private Label aboutLabel;
    }
}
namespace AddonManager.Forms
{
    partial class SettingsForm
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
            hidePacksCheckBox = new CheckBox();
            hideConsoleCheckBox = new CheckBox();
            generalHeaderLabel = new Label();
            experimentalHeaderLabel = new Label();
            SuspendLayout();
            // 
            // hidePacksCheckBox
            // 
            hidePacksCheckBox.AutoSize = true;
            hidePacksCheckBox.Font = new Font("Segoe UI Variable Small", 10F);
            hidePacksCheckBox.Location = new Point(12, 32);
            hidePacksCheckBox.Name = "hidePacksCheckBox";
            hidePacksCheckBox.Size = new Size(192, 23);
            hidePacksCheckBox.TabIndex = 0;
            hidePacksCheckBox.Text = "Hide default server packs";
            hidePacksCheckBox.UseVisualStyleBackColor = true;
            hidePacksCheckBox.CheckedChanged += hidePacksCheckBox_CheckedChanged;
            // 
            // hideConsoleCheckBox
            // 
            hideConsoleCheckBox.AutoSize = true;
            hideConsoleCheckBox.Font = new Font("Segoe UI Variable Small", 10F);
            hideConsoleCheckBox.Location = new Point(12, 61);
            hideConsoleCheckBox.Name = "hideConsoleCheckBox";
            hideConsoleCheckBox.Size = new Size(186, 23);
            hideConsoleCheckBox.TabIndex = 1;
            hideConsoleCheckBox.Text = "Hide debug console tab";
            hideConsoleCheckBox.UseVisualStyleBackColor = true;
            hideConsoleCheckBox.CheckedChanged += hideConsoleCheckBox_CheckedChanged;
            // 
            // generalHeaderLabel
            // 
            generalHeaderLabel.AutoSize = true;
            generalHeaderLabel.Font = new Font("Segoe UI Variable Small", 10F, FontStyle.Bold);
            generalHeaderLabel.Location = new Point(8, 9);
            generalHeaderLabel.Name = "generalHeaderLabel";
            generalHeaderLabel.Size = new Size(66, 19);
            generalHeaderLabel.TabIndex = 2;
            generalHeaderLabel.Text = "General:";
            // 
            // experimentalHeaderLabel
            // 
            experimentalHeaderLabel.AutoSize = true;
            experimentalHeaderLabel.Font = new Font("Segoe UI Variable Small", 10F, FontStyle.Bold);
            experimentalHeaderLabel.Location = new Point(8, 206);
            experimentalHeaderLabel.Name = "experimentalHeaderLabel";
            experimentalHeaderLabel.Size = new Size(104, 19);
            experimentalHeaderLabel.TabIndex = 3;
            experimentalHeaderLabel.Text = "Experimental:";
            experimentalHeaderLabel.Visible = false;
            // 
            // SettingsForm
            // 
            AutoScaleDimensions = new SizeF(7F, 16F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(748, 442);
            Controls.Add(experimentalHeaderLabel);
            Controls.Add(generalHeaderLabel);
            Controls.Add(hideConsoleCheckBox);
            Controls.Add(hidePacksCheckBox);
            Name = "SettingsForm";
            Text = "SettingsForm";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private CheckBox hidePacksCheckBox;
        private CheckBox hideConsoleCheckBox;
        private Label generalHeaderLabel;
        private Label experimentalHeaderLabel;
    }
}
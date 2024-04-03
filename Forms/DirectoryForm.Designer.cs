namespace AddonManager.Forms
{
    partial class DirectoryForm
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
            worldDirectoryTextBox = new TextBox();
            worldDirLabel = new Label();
            worldFilePicker = new Button();
            resourcePackPicker = new Button();
            label1 = new Label();
            rpDirectoryTextBox = new TextBox();
            behaviorPackPicker = new Button();
            label2 = new Label();
            bpDirectoryTextBox = new TextBox();
            validatePathsButton = new Button();
            worldNameLabel = new Label();
            warningLabel = new Label();
            SuspendLayout();
            // 
            // worldDirectoryTextBox
            // 
            worldDirectoryTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            worldDirectoryTextBox.Font = new Font("Segoe UI Variable Small", 10F);
            worldDirectoryTextBox.Location = new Point(28, 58);
            worldDirectoryTextBox.Name = "worldDirectoryTextBox";
            worldDirectoryTextBox.Size = new Size(677, 25);
            worldDirectoryTextBox.TabIndex = 0;
            // 
            // worldDirLabel
            // 
            worldDirLabel.AutoSize = true;
            worldDirLabel.Font = new Font("Segoe UI Variable Small", 12F);
            worldDirLabel.Location = new Point(28, 23);
            worldDirLabel.Name = "worldDirLabel";
            worldDirLabel.Size = new Size(129, 21);
            worldDirLabel.TabIndex = 1;
            worldDirLabel.Text = "World directory:";
            // 
            // worldFilePicker
            // 
            worldFilePicker.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            worldFilePicker.BackColor = Color.Transparent;
            worldFilePicker.Cursor = Cursors.Hand;
            worldFilePicker.FlatAppearance.BorderSize = 0;
            worldFilePicker.FlatStyle = FlatStyle.Flat;
            worldFilePicker.Image = Properties.Resources.folder;
            worldFilePicker.Location = new Point(703, 51);
            worldFilePicker.Name = "worldFilePicker";
            worldFilePicker.Size = new Size(38, 38);
            worldFilePicker.TabIndex = 2;
            worldFilePicker.UseVisualStyleBackColor = false;
            worldFilePicker.Click += worldFilePicker_Click;
            // 
            // resourcePackPicker
            // 
            resourcePackPicker.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            resourcePackPicker.BackColor = Color.Transparent;
            resourcePackPicker.Cursor = Cursors.Hand;
            resourcePackPicker.FlatAppearance.BorderSize = 0;
            resourcePackPicker.FlatStyle = FlatStyle.Flat;
            resourcePackPicker.Image = Properties.Resources.folder;
            resourcePackPicker.Location = new Point(703, 125);
            resourcePackPicker.Name = "resourcePackPicker";
            resourcePackPicker.Size = new Size(38, 38);
            resourcePackPicker.TabIndex = 5;
            resourcePackPicker.UseVisualStyleBackColor = false;
            resourcePackPicker.Click += resourcePackPicker_Click;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI Variable Small", 12F);
            label1.Location = new Point(28, 97);
            label1.Name = "label1";
            label1.Size = new Size(191, 21);
            label1.TabIndex = 4;
            label1.Text = "Resource pack directory:";
            // 
            // rpDirectoryTextBox
            // 
            rpDirectoryTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            rpDirectoryTextBox.Font = new Font("Segoe UI Variable Small", 10F);
            rpDirectoryTextBox.Location = new Point(28, 132);
            rpDirectoryTextBox.Name = "rpDirectoryTextBox";
            rpDirectoryTextBox.Size = new Size(677, 25);
            rpDirectoryTextBox.TabIndex = 3;
            // 
            // behaviorPackPicker
            // 
            behaviorPackPicker.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            behaviorPackPicker.BackColor = Color.Transparent;
            behaviorPackPicker.Cursor = Cursors.Hand;
            behaviorPackPicker.FlatAppearance.BorderSize = 0;
            behaviorPackPicker.FlatStyle = FlatStyle.Flat;
            behaviorPackPicker.Image = Properties.Resources.folder;
            behaviorPackPicker.Location = new Point(703, 198);
            behaviorPackPicker.Name = "behaviorPackPicker";
            behaviorPackPicker.Size = new Size(38, 38);
            behaviorPackPicker.TabIndex = 8;
            behaviorPackPicker.UseVisualStyleBackColor = false;
            behaviorPackPicker.Click += behaviorPackPicker_Click;
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI Variable Small", 12F);
            label2.Location = new Point(28, 170);
            label2.Name = "label2";
            label2.Size = new Size(186, 21);
            label2.TabIndex = 7;
            label2.Text = "Behavior pack directory:";
            // 
            // bpDirectoryTextBox
            // 
            bpDirectoryTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            bpDirectoryTextBox.Font = new Font("Segoe UI Variable Small", 10F);
            bpDirectoryTextBox.Location = new Point(28, 205);
            bpDirectoryTextBox.Name = "bpDirectoryTextBox";
            bpDirectoryTextBox.Size = new Size(677, 25);
            bpDirectoryTextBox.TabIndex = 6;
            // 
            // validatePathsButton
            // 
            validatePathsButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            validatePathsButton.Location = new Point(630, 256);
            validatePathsButton.Name = "validatePathsButton";
            validatePathsButton.Size = new Size(75, 23);
            validatePathsButton.TabIndex = 9;
            validatePathsButton.Text = "Validate";
            validatePathsButton.UseVisualStyleBackColor = true;
            validatePathsButton.Click += validatePathsButton_Click;
            // 
            // worldNameLabel
            // 
            worldNameLabel.AutoSize = true;
            worldNameLabel.Font = new Font("Segoe UI Variable Small", 10F);
            worldNameLabel.Location = new Point(28, 260);
            worldNameLabel.Name = "worldNameLabel";
            worldNameLabel.Size = new Size(170, 19);
            worldNameLabel.TabIndex = 10;
            worldNameLabel.Text = "Loaded world: My World";
            worldNameLabel.Visible = false;
            // 
            // warningLabel
            // 
            warningLabel.AutoSize = true;
            warningLabel.Dock = DockStyle.Bottom;
            warningLabel.Font = new Font("Segoe UI Variable Small", 10F);
            warningLabel.Location = new Point(0, 423);
            warningLabel.Name = "warningLabel";
            warningLabel.Size = new Size(65, 19);
            warningLabel.TabIndex = 11;
            warningLabel.Text = "Warning:";
            // 
            // DirectoryForm
            // 
            AutoScaleDimensions = new SizeF(7F, 16F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(748, 442);
            Controls.Add(warningLabel);
            Controls.Add(worldNameLabel);
            Controls.Add(validatePathsButton);
            Controls.Add(behaviorPackPicker);
            Controls.Add(label2);
            Controls.Add(bpDirectoryTextBox);
            Controls.Add(resourcePackPicker);
            Controls.Add(label1);
            Controls.Add(rpDirectoryTextBox);
            Controls.Add(worldFilePicker);
            Controls.Add(worldDirLabel);
            Controls.Add(worldDirectoryTextBox);
            Name = "DirectoryForm";
            Text = "DirectoryForm";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox worldDirectoryTextBox;
        private Label worldDirLabel;
        private Button worldFilePicker;
        private Button resourcePackPicker;
        private Label label1;
        private TextBox rpDirectoryTextBox;
        private Button behaviorPackPicker;
        private Label label2;
        private TextBox bpDirectoryTextBox;
        private Button validatePathsButton;
        private Label worldNameLabel;
        private Label warningLabel;
    }
}
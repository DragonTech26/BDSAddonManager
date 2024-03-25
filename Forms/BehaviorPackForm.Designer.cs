namespace AddonManager.Forms
{
    partial class BehaviorPackForm
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
            bpSplitContainer = new SplitContainer();
            bpInactiveListView = new ListView();
            ibpNameColumn = new ColumnHeader();
            ibpDescriptionColumn = new ColumnHeader();
            bpActiveListView = new ListView();
            bpNameColumn = new ColumnHeader();
            bpDescriptionColumn = new ColumnHeader();
            buttonPanel = new Panel();
            label2 = new Label();
            label1 = new Label();
            moveDownButton = new Button();
            moveUpButton = new Button();
            moveToActiveButton = new Button();
            moveToInactiveButton = new Button();
            ((System.ComponentModel.ISupportInitialize)bpSplitContainer).BeginInit();
            bpSplitContainer.Panel1.SuspendLayout();
            bpSplitContainer.Panel2.SuspendLayout();
            bpSplitContainer.SuspendLayout();
            buttonPanel.SuspendLayout();
            SuspendLayout();
            // 
            // bpSplitContainer
            // 
            bpSplitContainer.Dock = DockStyle.Fill;
            bpSplitContainer.IsSplitterFixed = true;
            bpSplitContainer.Location = new Point(0, 0);
            bpSplitContainer.Name = "bpSplitContainer";
            // 
            // bpSplitContainer.Panel1
            // 
            bpSplitContainer.Panel1.Controls.Add(bpInactiveListView);
            // 
            // bpSplitContainer.Panel2
            // 
            bpSplitContainer.Panel2.Controls.Add(bpActiveListView);
            bpSplitContainer.Size = new Size(748, 397);
            bpSplitContainer.SplitterDistance = 374;
            bpSplitContainer.TabIndex = 0;
            // 
            // bpInactiveListView
            // 
            bpInactiveListView.BorderStyle = BorderStyle.None;
            bpInactiveListView.Columns.AddRange(new ColumnHeader[] { ibpNameColumn, ibpDescriptionColumn });
            bpInactiveListView.Dock = DockStyle.Fill;
            bpInactiveListView.Font = new Font("Segoe UI Variable Small", 10F);
            bpInactiveListView.FullRowSelect = true;
            bpInactiveListView.GridLines = true;
            bpInactiveListView.Location = new Point(0, 0);
            bpInactiveListView.MultiSelect = false;
            bpInactiveListView.Name = "bpInactiveListView";
            bpInactiveListView.Size = new Size(374, 397);
            bpInactiveListView.TabIndex = 0;
            bpInactiveListView.UseCompatibleStateImageBehavior = false;
            bpInactiveListView.View = View.Details;
            bpInactiveListView.MouseClick += ListView_MouseClick;
            // 
            // ibpNameColumn
            // 
            ibpNameColumn.Text = "Name";
            ibpNameColumn.Width = 200;
            // 
            // ibpDescriptionColumn
            // 
            ibpDescriptionColumn.Text = "Description";
            ibpDescriptionColumn.Width = 300;
            // 
            // bpActiveListView
            // 
            bpActiveListView.BorderStyle = BorderStyle.None;
            bpActiveListView.Columns.AddRange(new ColumnHeader[] { bpNameColumn, bpDescriptionColumn });
            bpActiveListView.Dock = DockStyle.Fill;
            bpActiveListView.Font = new Font("Segoe UI Variable Small", 10F);
            bpActiveListView.FullRowSelect = true;
            bpActiveListView.GridLines = true;
            bpActiveListView.Location = new Point(0, 0);
            bpActiveListView.MultiSelect = false;
            bpActiveListView.Name = "bpActiveListView";
            bpActiveListView.Size = new Size(370, 397);
            bpActiveListView.TabIndex = 1;
            bpActiveListView.UseCompatibleStateImageBehavior = false;
            bpActiveListView.View = View.Details;
            bpActiveListView.MouseClick += ListView_MouseClick;
            // 
            // bpNameColumn
            // 
            bpNameColumn.Text = "Name";
            bpNameColumn.Width = 200;
            // 
            // bpDescriptionColumn
            // 
            bpDescriptionColumn.Text = "Description";
            bpDescriptionColumn.Width = 300;
            // 
            // buttonPanel
            // 
            buttonPanel.Controls.Add(label2);
            buttonPanel.Controls.Add(label1);
            buttonPanel.Controls.Add(moveDownButton);
            buttonPanel.Controls.Add(moveUpButton);
            buttonPanel.Controls.Add(moveToActiveButton);
            buttonPanel.Controls.Add(moveToInactiveButton);
            buttonPanel.Dock = DockStyle.Bottom;
            buttonPanel.Location = new Point(0, 397);
            buttonPanel.Name = "buttonPanel";
            buttonPanel.Size = new Size(748, 45);
            buttonPanel.TabIndex = 1;
            // 
            // label2
            // 
            label2.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI Variable Small", 10F);
            label2.Location = new Point(648, 13);
            label2.Name = "label2";
            label2.Size = new Size(88, 19);
            label2.TabIndex = 6;
            label2.Text = "Active Packs";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI Variable Small", 10F);
            label1.Location = new Point(12, 13);
            label1.Name = "label1";
            label1.Size = new Size(107, 19);
            label1.TabIndex = 5;
            label1.Text = "Available Packs";
            // 
            // moveDownButton
            // 
            moveDownButton.Anchor = AnchorStyles.None;
            moveDownButton.Font = new Font("Segoe UI Variable Small", 10F);
            moveDownButton.Location = new Point(299, 10);
            moveDownButton.Name = "moveDownButton";
            moveDownButton.Size = new Size(75, 26);
            moveDownButton.TabIndex = 3;
            moveDownButton.Text = "▼";
            moveDownButton.UseVisualStyleBackColor = true;
            moveDownButton.Click += moveDownButton_Click;
            // 
            // moveUpButton
            // 
            moveUpButton.Anchor = AnchorStyles.None;
            moveUpButton.Font = new Font("Segoe UI Variable Small", 10F);
            moveUpButton.Location = new Point(378, 10);
            moveUpButton.Name = "moveUpButton";
            moveUpButton.Size = new Size(75, 26);
            moveUpButton.TabIndex = 2;
            moveUpButton.Text = "▲";
            moveUpButton.UseVisualStyleBackColor = true;
            moveUpButton.Click += moveUpButton_Click;
            // 
            // moveToActiveButton
            // 
            moveToActiveButton.Anchor = AnchorStyles.None;
            moveToActiveButton.Font = new Font("Segoe UI Variable Small", 9.5F);
            moveToActiveButton.Location = new Point(459, 10);
            moveToActiveButton.Name = "moveToActiveButton";
            moveToActiveButton.Size = new Size(75, 26);
            moveToActiveButton.TabIndex = 1;
            moveToActiveButton.Text = "▶";
            moveToActiveButton.UseVisualStyleBackColor = true;
            moveToActiveButton.Click += moveToActiveButton_Click;
            // 
            // moveToInactiveButton
            // 
            moveToInactiveButton.Anchor = AnchorStyles.None;
            moveToInactiveButton.Font = new Font("Segoe UI Variable Small", 9.5F);
            moveToInactiveButton.Location = new Point(218, 10);
            moveToInactiveButton.Name = "moveToInactiveButton";
            moveToInactiveButton.Size = new Size(75, 26);
            moveToInactiveButton.TabIndex = 0;
            moveToInactiveButton.Text = "◀";
            moveToInactiveButton.UseVisualStyleBackColor = true;
            moveToInactiveButton.Click += moveToInactiveButton_Click;
            // 
            // BehaviorPackForm
            // 
            AutoScaleDimensions = new SizeF(7F, 16F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(748, 442);
            Controls.Add(bpSplitContainer);
            Controls.Add(buttonPanel);
            Name = "BehaviorPackForm";
            Text = "BehaviorPackForm";
            bpSplitContainer.Panel1.ResumeLayout(false);
            bpSplitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)bpSplitContainer).EndInit();
            bpSplitContainer.ResumeLayout(false);
            buttonPanel.ResumeLayout(false);
            buttonPanel.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private SplitContainer bpSplitContainer;
        private Panel buttonPanel;
        private ListView bpInactiveListView;
        private ColumnHeader ibpNameColumn;
        private ColumnHeader ibpDescriptionColumn;
        private ListView bpActiveListView;
        private ColumnHeader bpNameColumn;
        private ColumnHeader bpDescriptionColumn;
        private Button moveToInactiveButton;
        private Button moveToActiveButton;
        private Button moveDownButton;
        private Button moveUpButton;
        private Label label2;
        private Label label1;
    }
}
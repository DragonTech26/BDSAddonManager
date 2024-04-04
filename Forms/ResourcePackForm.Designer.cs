namespace AddonManager.Forms
{
    partial class ResourcePackForm
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
            rpSplitContainer = new SplitContainer();
            rpInactiveListView = new ListView();
            irpNameColumn = new ColumnHeader();
            irpDescriptionColumn = new ColumnHeader();
            irpVersionColumn = new ColumnHeader();
            rpActiveListView = new ListView();
            rpNameColumn = new ColumnHeader();
            rpDescriptionColumn = new ColumnHeader();
            rpVersionColumn = new ColumnHeader();
            moveDownButton = new Button();
            moveUpButton = new Button();
            moveToInactiveButton = new Button();
            moveToActiveButton = new Button();
            columnHeader3 = new ColumnHeader();
            buttonPanel = new Panel();
            label2 = new Label();
            label1 = new Label();
            ((System.ComponentModel.ISupportInitialize)rpSplitContainer).BeginInit();
            rpSplitContainer.Panel1.SuspendLayout();
            rpSplitContainer.Panel2.SuspendLayout();
            rpSplitContainer.SuspendLayout();
            buttonPanel.SuspendLayout();
            SuspendLayout();
            // 
            // rpSplitContainer
            // 
            rpSplitContainer.Dock = DockStyle.Fill;
            rpSplitContainer.IsSplitterFixed = true;
            rpSplitContainer.Location = new Point(0, 0);
            rpSplitContainer.Name = "rpSplitContainer";
            // 
            // rpSplitContainer.Panel1
            // 
            rpSplitContainer.Panel1.Controls.Add(rpInactiveListView);
            // 
            // rpSplitContainer.Panel2
            // 
            rpSplitContainer.Panel2.Controls.Add(rpActiveListView);
            rpSplitContainer.Size = new Size(748, 397);
            rpSplitContainer.SplitterDistance = 374;
            rpSplitContainer.TabIndex = 0;
            // 
            // rpInactiveListView
            // 
            rpInactiveListView.AllowDrop = true;
            rpInactiveListView.BorderStyle = BorderStyle.None;
            rpInactiveListView.Columns.AddRange(new ColumnHeader[] { irpNameColumn, irpDescriptionColumn, irpVersionColumn });
            rpInactiveListView.Dock = DockStyle.Fill;
            rpInactiveListView.Font = new Font("Segoe UI Variable Small", 10F);
            rpInactiveListView.FullRowSelect = true;
            rpInactiveListView.GridLines = true;
            rpInactiveListView.Location = new Point(0, 0);
            rpInactiveListView.MultiSelect = false;
            rpInactiveListView.Name = "rpInactiveListView";
            rpInactiveListView.Size = new Size(374, 397);
            rpInactiveListView.TabIndex = 0;
            rpInactiveListView.UseCompatibleStateImageBehavior = false;
            rpInactiveListView.View = View.Details;
            rpInactiveListView.DragDrop += rpInactiveListView_DragDrop;
            rpInactiveListView.DragEnter += rpInactiveListView_DragEnter;
            rpInactiveListView.MouseClick += ListView_MouseClick;
            // 
            // irpNameColumn
            // 
            irpNameColumn.Text = "Name";
            irpNameColumn.Width = 200;
            // 
            // irpDescriptionColumn
            // 
            irpDescriptionColumn.Text = "Description";
            irpDescriptionColumn.Width = 300;
            // 
            // irpVersionColumn
            // 
            irpVersionColumn.Text = "Version";
            // 
            // rpActiveListView
            // 
            rpActiveListView.BorderStyle = BorderStyle.None;
            rpActiveListView.Columns.AddRange(new ColumnHeader[] { rpNameColumn, rpDescriptionColumn, rpVersionColumn });
            rpActiveListView.Dock = DockStyle.Fill;
            rpActiveListView.Font = new Font("Segoe UI Variable Small", 10F);
            rpActiveListView.FullRowSelect = true;
            rpActiveListView.GridLines = true;
            rpActiveListView.Location = new Point(0, 0);
            rpActiveListView.MultiSelect = false;
            rpActiveListView.Name = "rpActiveListView";
            rpActiveListView.Size = new Size(370, 397);
            rpActiveListView.TabIndex = 0;
            rpActiveListView.UseCompatibleStateImageBehavior = false;
            rpActiveListView.View = View.Details;
            rpActiveListView.MouseClick += ListView_MouseClick;
            // 
            // rpNameColumn
            // 
            rpNameColumn.Text = "Name";
            rpNameColumn.Width = 200;
            // 
            // rpDescriptionColumn
            // 
            rpDescriptionColumn.Text = "Description";
            rpDescriptionColumn.Width = 300;
            // 
            // rpVersionColumn
            // 
            rpVersionColumn.Text = "Version";
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
            // moveToInactiveButton
            // 
            moveToInactiveButton.Anchor = AnchorStyles.None;
            moveToInactiveButton.Font = new Font("Segoe UI Variable Small", 9.5F);
            moveToInactiveButton.Location = new Point(218, 10);
            moveToInactiveButton.Name = "moveToInactiveButton";
            moveToInactiveButton.Size = new Size(75, 26);
            moveToInactiveButton.TabIndex = 1;
            moveToInactiveButton.Text = "◀";
            moveToInactiveButton.UseVisualStyleBackColor = true;
            moveToInactiveButton.Click += moveToInactiveButton_Click;
            // 
            // moveToActiveButton
            // 
            moveToActiveButton.Anchor = AnchorStyles.None;
            moveToActiveButton.Font = new Font("Segoe UI Variable Small", 9.5F);
            moveToActiveButton.Location = new Point(459, 10);
            moveToActiveButton.Name = "moveToActiveButton";
            moveToActiveButton.Size = new Size(75, 26);
            moveToActiveButton.TabIndex = 0;
            moveToActiveButton.Text = "▶";
            moveToActiveButton.UseVisualStyleBackColor = true;
            moveToActiveButton.Click += moveToActiveButton_Click;
            // 
            // buttonPanel
            // 
            buttonPanel.Controls.Add(label2);
            buttonPanel.Controls.Add(label1);
            buttonPanel.Controls.Add(moveToInactiveButton);
            buttonPanel.Controls.Add(moveUpButton);
            buttonPanel.Controls.Add(moveToActiveButton);
            buttonPanel.Controls.Add(moveDownButton);
            buttonPanel.Dock = DockStyle.Bottom;
            buttonPanel.Location = new Point(0, 397);
            buttonPanel.Name = "buttonPanel";
            buttonPanel.Size = new Size(748, 45);
            buttonPanel.TabIndex = 4;
            // 
            // label2
            // 
            label2.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI Variable Small", 10F);
            label2.Location = new Point(648, 13);
            label2.Name = "label2";
            label2.Size = new Size(88, 19);
            label2.TabIndex = 5;
            label2.Text = "Active Packs";
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI Variable Small", 10F);
            label1.Location = new Point(12, 13);
            label1.Name = "label1";
            label1.Size = new Size(107, 19);
            label1.TabIndex = 4;
            label1.Text = "Available Packs";
            // 
            // ResourcePackForm
            // 
            AutoScaleDimensions = new SizeF(7F, 16F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(748, 442);
            Controls.Add(rpSplitContainer);
            Controls.Add(buttonPanel);
            Name = "ResourcePackForm";
            rpSplitContainer.Panel1.ResumeLayout(false);
            rpSplitContainer.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)rpSplitContainer).EndInit();
            rpSplitContainer.ResumeLayout(false);
            buttonPanel.ResumeLayout(false);
            buttonPanel.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private SplitContainer rpSplitContainer;
        private ListView rpInactiveListView;
        private ColumnHeader irpNameColumn;
        private ColumnHeader irpDescriptionColumn;
        private ColumnHeader columnHeader3;
        private ListView rpActiveListView;
        private ColumnHeader rpNameColumn;
        private ColumnHeader rpDescriptionColumn;
        private Button moveToActiveButton;
        private Button moveToInactiveButton;
        private Button moveDownButton;
        private Button moveUpButton;
        private Panel buttonPanel;
        private Label label2;
        private Label label1;
        private ColumnHeader irpVersionColumn;
        private ColumnHeader rpVersionColumn;
    }
}
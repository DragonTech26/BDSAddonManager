
namespace AddonManager.Forms
{
    public partial class BehaviorPackForm : Form
    {
        PackHandler packHandler = new PackHandler();

        public BehaviorPackForm()
        {
            InitializeComponent();
            this.Text = "SELECT BEHAVIOR PACKS";
            packHandler.FormDeclaration(bpInactiveListView, bpActiveListView, "inactiveBpList", "activeBpList");
            packHandler.InactiveListPopulate();
            packHandler.ActiveListPopulate();
        }
        private void moveToInactiveButton_Click(object sender, EventArgs e) 
        {
            // Move items from the active to the inactive list
            packHandler.MoveSelectedItems(bpActiveListView, bpInactiveListView, ResultLists.activeBpList, ResultLists.inactiveBpList);
        }
        private void moveToActiveButton_Click(object sender, EventArgs e) 
        {
            // Move items from the inactive to the active list
            packHandler.MoveSelectedItems(bpInactiveListView, bpActiveListView, ResultLists.inactiveBpList, ResultLists.activeBpList);
        }
        private void moveUpButton_Click(object sender, EventArgs e) 
        {
            // Move item up in list
            packHandler.MoveItemUpOrDown(bpActiveListView, ResultLists.activeBpList, -1);
        }
        private void moveDownButton_Click(object sender, EventArgs e) 
        {
            // Move item down in list
            packHandler.MoveItemUpOrDown(bpActiveListView, ResultLists.activeBpList, 1);
        }
        private void ListView_MouseDown(object sender, MouseEventArgs e)
        {
            // Handle right click menu detection
            packHandler.HandleMouseClick(sender, e, openFolderOption_Click, deletePackOption_Click, importPackOption_Click);
        }
        private void bpInactiveListView_DragEnter(object sender, DragEventArgs e) 
        {
            // Handles detection for importing packs
            packHandler.DragEnterHandler(e);
        }
        private void bpInactiveListView_DragDrop(object sender, DragEventArgs e) 
        {
            // Handles the importing of packs
            packHandler.DragDropHandler(e, DirectoryForm.bpLocation);
        }
        private void openFolderOption_Click(ListViewItem item) 
        {
            // Opens file explorer to selected pack folder
            packHandler.OpenFolder(item);
        }
        private void deletePackOption_Click(ListViewItem item) 
        {
            // Deletes selected pack
            packHandler.DeletePack(item);
        }
        private void importPackOption_Click()
        {
            // Opens a file picker
            packHandler.ImportPack(DirectoryForm.bpLocation);
        }
    }
}

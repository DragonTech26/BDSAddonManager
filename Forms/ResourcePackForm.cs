
namespace AddonManager.Forms
{
    public partial class ResourcePackForm : Form
    {
        PackHandler packHandler = new PackHandler();

        public ResourcePackForm()
        {
            InitializeComponent();
            this.Text = "SELECT RESOURCE PACKS";
            packHandler.FormDeclaration(rpInactiveListView, rpActiveListView, "inactiveRpList", "activeRpList");
            packHandler.InactiveListPopulate();
            packHandler.ActiveListPopulate();
        }
        private void moveToInactiveButton_Click(object sender, EventArgs e)
        {
            // Move items from the active to the inactive list
            packHandler.MoveSelectedItems(rpActiveListView, rpInactiveListView, ResultLists.activeRpList, ResultLists.inactiveRpList);
        }
        private void moveToActiveButton_Click(object sender, EventArgs e) 
        {
            // Move items from the inactive to the active list
            packHandler.MoveSelectedItems(rpInactiveListView, rpActiveListView, ResultLists.inactiveRpList, ResultLists.activeRpList); 
        }
        private void moveUpButton_Click(object sender, EventArgs e) 
        {
            // Move item up in list
            packHandler.MoveItemUpOrDown(rpActiveListView, ResultLists.activeRpList, -1);
        }
        private void moveDownButton_Click(object sender, EventArgs e) 
        {
            // Move item down in list
            packHandler.MoveItemUpOrDown(rpActiveListView, ResultLists.activeRpList, 1);
        }
        private void ListView_MouseClick(object sender, MouseEventArgs e) 
        {
            // Handle right click menu detection
            packHandler.HandleMouseClick(sender, e, openFolderOption_Click, deletePackOption_Click, importPackOption_Click);
        }
        private void rpInactiveListView_DragEnter(object sender, DragEventArgs e) 
        {
            // Handles detection for importing packs
            packHandler.DragEnterHandler(e);
        }
        private void rpInactiveListView_DragDrop(object sender, DragEventArgs e) 
        {
            // Handles the importing of packs
            packHandler.DragDropHandler(e, DirectoryForm.rpLocation);
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
            packHandler.ImportPack();
        }
    }
}
    


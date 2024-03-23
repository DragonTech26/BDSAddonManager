using System.Data;

namespace AddonManager.Forms
{
    public partial class ResourcePackForm : Form
    {
        public ResourcePackForm()
        {
            InitializeComponent();
            this.Text = "SELECT RESOURCE PACKS"; //Header title
            InactiveListPopulate();
            ActiveListPopulate();
        }
        private void InactiveListPopulate()
        {
            rpInactiveListView.BeginUpdate(); //Prevent the control from drawing until the EndUpdate method is called. Used mainly for large lists
            foreach (var pack in ResultLists.inactiveRpList)
            {
                ListViewItem item = new ListViewItem(pack.name);
                item.SubItems.Add(pack.description);
                item.Tag = pack;
                rpInactiveListView.Items.Add(item);
            }
            rpInactiveListView.EndUpdate(); //Enable the control to redraw
        }
        private void ActiveListPopulate()
        {
            rpActiveListView.BeginUpdate();
            foreach (var pack in ResultLists.activeRpList)
            {
                ListViewItem item = new ListViewItem(pack.name);
                item.SubItems.Add(pack.description);
                item.Tag = pack;
                rpActiveListView.Items.Add(item);
            }
            rpActiveListView.EndUpdate();
        }
        private void MoveSelectedItems(System.Windows.Forms.ListView source, System.Windows.Forms.ListView destination, List<ManifestInfo> sourceList, List<ManifestInfo> destinationList)
        {
            var itemsToMove = source.SelectedItems.Cast<ListViewItem>().ToList(); //Get the selected items to move
            foreach (ListViewItem item in itemsToMove) //Iterate through the selected items
            {
                var pack = (ManifestInfo)item.Tag; //Retrieve the full data object from the Tag property
                sourceList.Remove(pack); //Remove the pack from the source list
                destinationList.Add(pack); //Add the pack to the destination list

                source.Items.Remove(item); //Remove the item from the source list view
                destination.Items.Add(item); //Add the item to the destination list view
            }
        }
        private void moveToInactiveButton_Click(object sender, EventArgs e)
        {
            MoveSelectedItems(rpActiveListView, rpInactiveListView, ResultLists.activeRpList, ResultLists.inactiveRpList); //Move items from the active to the inactive list
        }
        private void moveToActiveButton_Click(object sender, EventArgs e)
        {
            MoveSelectedItems(rpInactiveListView, rpActiveListView, ResultLists.inactiveRpList, ResultLists.activeRpList); //Move items from the inactive to the active list
        }
        private void moveUpButton_Click(object sender, EventArgs e)
        {
            if (rpActiveListView.SelectedItems.Count > 0)
            {
                var selectedItem = rpActiveListView.SelectedItems[0];
                int index = selectedItem.Index;
                if (index > 0)
                {
                    rpActiveListView.Items.Remove(selectedItem);
                    rpActiveListView.Items.Insert(index - 1, selectedItem);
                    ResultLists.activeRpList.Move(index, index - 1);
                }
            }
        }
        private void moveDownButton_Click(object sender, EventArgs e)
        {
            if (rpActiveListView.SelectedItems.Count > 0)
            {
                var selectedItem = rpActiveListView.SelectedItems[0];
                int index = selectedItem.Index;
                if (index < rpActiveListView.Items.Count - 1)
                {
                    rpActiveListView.Items.Remove(selectedItem);
                    rpActiveListView.Items.Insert(index + 1, selectedItem);
                    ResultLists.activeRpList.Move(index, index + 1);
                }
            }
        }
    }
}

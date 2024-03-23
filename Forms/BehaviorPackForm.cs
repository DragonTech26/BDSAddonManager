using System.Data;

namespace AddonManager.Forms
{
    public partial class BehaviorPackForm : Form
    {
        public BehaviorPackForm()
        {
            InitializeComponent();
            this.Text = "SELECT BEHAVIOR PACKS"; //Header title
            InactiveListPopulate();
            ActiveListPopulate();
        }
        private void InactiveListPopulate()
        {
            bpInactiveListView.BeginUpdate(); //Prevent the control from drawing until the EndUpdate method is called. Optimized for large lists
            foreach (var pack in ResultLists.inactiveBpList)
            {
                ListViewItem item = new ListViewItem(pack.name);
                item.SubItems.Add(pack.description);
                item.Tag = pack;
                bpInactiveListView.Items.Add(item);
            }
            bpInactiveListView.EndUpdate(); //Enable the control to redraw
        }
        private void ActiveListPopulate()
        {
            bpActiveListView.BeginUpdate();
            foreach (var pack in ResultLists.activeBpList)
            {
                ListViewItem item = new ListViewItem(pack.name);
                item.SubItems.Add(pack.description);
                item.Tag = pack;
                bpActiveListView.Items.Add(item);
            }
            bpActiveListView.EndUpdate();
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
            MoveSelectedItems(bpActiveListView, bpInactiveListView, ResultLists.activeBpList, ResultLists.inactiveBpList); //Move items from the active to the inactive list
        }
        private void moveToActiveButton_Click(object sender, EventArgs e)
        {
            MoveSelectedItems(bpInactiveListView, bpActiveListView, ResultLists.inactiveBpList, ResultLists.activeBpList); //Move items from the inactive to the active list
        }
        private void moveUpButton_Click(object sender, EventArgs e)
        {
            if (bpActiveListView.SelectedItems.Count > 0)
            {
                var selectedItem = bpActiveListView.SelectedItems[0];
                int index = selectedItem.Index;
                if (index > 0)
                {
                    bpActiveListView.Items.Remove(selectedItem);
                    bpActiveListView.Items.Insert(index - 1, selectedItem);
                    ResultLists.activeBpList.Move(index, index - 1);
                }
            }
        }
        private void moveDownButton_Click(object sender, EventArgs e)
        {
            if (bpActiveListView.SelectedItems.Count > 0)
            {
                var selectedItem = bpActiveListView.SelectedItems[0];
                int index = selectedItem.Index;
                if (index < bpActiveListView.Items.Count - 1)
                {
                    bpActiveListView.Items.Remove(selectedItem);
                    bpActiveListView.Items.Insert(index + 1, selectedItem);
                    ResultLists.activeBpList.Move(index, index + 1);
                }
            }
        }
    }
}

import { useState } from "react";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DriveFileRenameOutlineRounded } from "@mui/icons-material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import { TChildCategory, TModalState, } from "../types";
import { useGetAllChildCategoryQuery } from "../redux/features/childCategory/childCategoryApi";
import UpdateChildCategoryModal from "../components/ui/childCategory/UpdateChildCategoryModal";
import AddChildCategoryModal from "../components/ui/childCategory/AddChildCategoryModal";
// import GetPermission from "../utils/getPermission";
// import { toast } from "sonner";

const ChildCategory = () => {
  const [modalState, setModalState] = useState<TModalState<TChildCategory>>({
    type: null,
  });
  const { data, isFetching } = useGetAllChildCategoryQuery(undefined);
  // const { edit } = GetPermission("child-category") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TChildCategory>[] = [
    {
      field: "child_category_name",
      headerName: "Name",
      minWidth: 200,
      flex: 1,
    },
    {
      field: "icon",
      headerName: "Icon",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.icon}`}
            alt="icon"
            style={{ maxHeight: 40 }}
          />
        </Stack>
      ),
      minWidth: 50,
      flex: 1,
    },
    {
      field: "banner",
      headerName: "Banner",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.banner}`}
            alt="icon"
            style={{ maxHeight: 40 }}
          />
        </Stack>
      ),
      minWidth: 50,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      headerAlign: "right",
      renderCell: ({ row }) => (
        <Stack
          direction="row"
          justifyContent="end"
          alignItems="center"
          height="100%"
        >
          <IconButton onClick={() => handleUpdate(row)} aria-label="view">
            <DriveFileRenameOutlineRounded color="success" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleUpdate = (data: TChildCategory) => {
    setModalState({ type: "edit", data });
    // if (!edit) {
    //   toast.error("You don't have permission");
    // } else {
    // }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Child Category" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Child Category
        </Button>
      </Stack>
      <Box
        mt="20px"
        sx={{ border: "1px solid #E0E2E7" }}
        borderRadius={2}
        bgcolor="white"
        overflow="hidden"
      >
        <MyDataGrid rows={rowsData} columns={columns} loading={isFetching} />
      </Box>

      <AddChildCategoryModal
        open={modalState.type === "add"}
        setOpen={closeModal}
      />
      {modalState.type === "edit" && (
        <UpdateChildCategoryModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TChildCategory}
        />
      )}
    </>
  );
};

export default ChildCategory;

import { useState } from "react";
import { TBlogCategory, TModalState, TPermissions } from "../types";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import handleAsyncToast from "../utils/handleAsyncToast";
import { Box, Button, IconButton, Stack } from "@mui/material";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import HeaderTitle from "../components/seo/HeaderTitle";
import AddBlogCategoryModal from "../components/ui/blogCategory/AddBlogCategoryModal";
import UpdateBlogCategoryModal from "../components/ui/blogCategory/UpdateBlogCategoryModal";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import {
  useDeleteBlogCategoryMutation,
  useGetAllBlogCategoryQuery,
} from "../redux/features/blogCategory/blogCategoryApi";
import dayjs from "dayjs";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const BlogCategory = () => {
  const [modalState, setModalState] = useState<TModalState<TBlogCategory>>({
    type: null,
  });
  const { data, isFetching } = useGetAllBlogCategoryQuery(undefined);
  const [deleteBlog] = useDeleteBlogCategoryMutation();
  const { delete: del, edit } = GetPermission("blog-category") as TPermissions;
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TBlogCategory>[] = [
    {
      field: "name",
      headerName: "Name",
      minWidth: 200,
      flex: 1,
    },
    {
      field: "updated_at",
      headerName: "Date",
      renderCell: ({ row }) => dayjs(row.created_at).format("D MMM YYYY"),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton onClick={() => handleEditModal(row)} aria-label="edit">
            <EditRounded color="success" />
          </IconButton>
          <IconButton
            onClick={() => setModalState({ type: "delete", data: row })}
            aria-label="delete"
          >
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TBlogCategory) => {
    if (!edit) {
      toast.error("You don't have permission");
    } else {
      setModalState({ type: "edit", data });
    }
  };
  const handleDelete = async (id: number) => {
    if (!del) {
      toast.error("You don't have permission");
    } else {
      handleAsyncToast({
        promise: deleteBlog(id).unwrap(),
        success: () => {
          return "Item deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Blog Category" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Blog Category" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Category
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

      <AddBlogCategoryModal
        open={modalState.type === "add"}
        setOpen={closeModal}
      />
      {modalState.type === "edit" && (
        <UpdateBlogCategoryModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TBlogCategory}
        />
      )}
      {modalState.type === "delete" && (
        <RCConfirmationModal
          open={modalState.type === "delete"}
          setOpen={closeModal}
          handleDelete={() => handleDelete(modalState.data?.id as number)}
        />
      )}
    </>
  );
};

export default BlogCategory;

import { Box, Button, IconButton, Stack } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import { useState } from "react";
import { TBlog, TModalState, TPermissions } from "../types";
import {
  useDeleteBlogMutation,
  useGetAllBlogQuery,
} from "../redux/features/blog/blogApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import dayjs from "dayjs";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
  VisibilityRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import AddBlogModal from "../components/ui/blog/AddBlogModal";
import ViewBlogModal from "../components/ui/blog/ViewBlogModal";
import UpdateBlogModal from "../components/ui/blog/UpdateBlogModal";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const Blogs = () => {
  const [modalState, setModalState] = useState<TModalState<TBlog>>({
    type: null,
  });
  const { data, isFetching } = useGetAllBlogQuery(undefined);
  const rowsData: GridValidRowModel[] = data?.data || [];
  const [deleteBlog] = useDeleteBlogMutation();
  const { edit, delete: del } = GetPermission("blogs") as TPermissions;

  const columns: GridColDef<TBlog>[] = [
    {
      field: "blog_title",
      headerName: "Title",
      minWidth: 150,
      flex: 1,
    },
    {
      field: "blog_thumb_img",
      headerName: "Thumb Img",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.blog_thumb_img}`}
            alt="icon"
            style={{ maxHeight: 40 }}
          />
        </Stack>
      ),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "update_at",
      headerName: "Date",
      renderCell: ({ row }) => dayjs(row.updated_at).format("DD MMM YYYY"),
      minWidth: 150,
      flex: 1,
    },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton
            onClick={() => setModalState({ type: "view", data: row })}
            aria-label="view"
          >
            <VisibilityRounded color="primary" />
          </IconButton>
          <IconButton onClick={() => handleEditModal(row)} aria-label="edit">
            <DriveFileRenameOutlineRounded color="success" />
          </IconButton>
          <IconButton onClick={() => handleDelete(row.id)} aria-label="delete">
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleEditModal = (data: TBlog) => {
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
          return "Blog deleted successfully!";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Blogs" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Blogs" />
        <Button onClick={() => setModalState({ type: "add" })}>Add Blog</Button>
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
      <AddBlogModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "view" && (
        <ViewBlogModal
          open={modalState.type === "view"}
          setOpen={closeModal}
          data={modalState.data as TBlog}
        />
      )}
      {modalState.type === "edit" && (
        <UpdateBlogModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TBlog}
        />
      )}
    </>
  );
};

export default Blogs;

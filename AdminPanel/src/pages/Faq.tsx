import { useState } from "react";
import {
  useDeleteFaqMutation,
  useGetAllFaqQuery,
} from "../redux/features/faq/faqApi";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { Box, Button, IconButton, Stack } from "@mui/material";
import {
  DeleteRounded,
  DriveFileRenameOutlineRounded,
} from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddFaqModal from "../components/ui/faq/AddFaqModal";
import UpdateFaqModal from "../components/ui/faq/UpdateFaqModal";
import { TFaq, TModalState, TPermissions } from "../types";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";
import GetPermission from "../utils/getPermission";
import { toast } from "sonner";

const Faq = () => {
  const [modalState, setModalState] = useState<TModalState<TFaq>>({
    type: null,
  });
  const { data, isFetching } = useGetAllFaqQuery(undefined);
  const [deleteFaq] = useDeleteFaqMutation();
  const { delete: del, edit } = GetPermission("faqs") as TPermissions;

  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef[] = [
    { field: "qua", headerName: "Question", minWidth: 250, flex: 1 },
    { field: "ans", headerName: "Answer", minWidth: 250, flex: 1 },
    {
      field: "action",
      headerName: "Action",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <IconButton onClick={() => handleUpdate(row)}>
            <DriveFileRenameOutlineRounded color="success" />
          </IconButton>
          <IconButton
            onClick={() => setModalState({ type: "delete", data: row })}
          >
            <DeleteRounded color="error" />
          </IconButton>
        </Stack>
      ),
      minWidth: 140,
      flex: 1,
    },
  ];

  const handleUpdate = (data: TFaq) => {
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
        promise: deleteFaq(id).unwrap(),
        success: () => {
          return "Faq deleted successfully";
        },
      });
    }
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="FAQ" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="FAQ" />
        <Button onClick={() => setModalState({ type: "add" })}>Add Faq</Button>
      </Stack>
      <Box
        mt="20px"
        bgcolor="white"
        borderRadius={2}
        border="1px solid #E0E7E2"
        overflow="hidden"
      >
        <MyDataGrid rows={rowsData} columns={columns} loading={isFetching} />
      </Box>

      <AddFaqModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateFaqModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TFaq}
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

export default Faq;

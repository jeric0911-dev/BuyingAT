import { Box, Button, IconButton, Stack } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import { useState } from "react";
import { TModalState, TSlider } from "../types";
import { GridColDef, GridValidRowModel } from "@mui/x-data-grid";
import { DeleteRounded, EditRounded } from "@mui/icons-material";
import handleAsyncToast from "../utils/handleAsyncToast";
import MyDataGrid from "../components/dataGrid/MyDataGrid";
import AddSliderModal from "../components/ui/slider/AddSliderModal";
import UpdateSliderModal from "../components/ui/slider/UpdateSliderModal";
import {
  useDeleteSliderMutation,
  useGetAllSliderQuery,
} from "../redux/features/frontend/advertisementApi";
import dayjs from "dayjs";
import RCConfirmationModal from "../components/modal/RCConfirmationModal";

const Slider = () => {
  const [modalState, setModalState] = useState<TModalState<TSlider>>({
    type: null,
  });
  const { data, isFetching } = useGetAllSliderQuery(undefined);
  const [deleteSlider] = useDeleteSliderMutation();
  const rowsData: GridValidRowModel[] = data?.data || [];

  const columns: GridColDef<TSlider>[] = [
    {
      field: "img",
      headerName: "Image",
      renderCell: ({ row }) => (
        <Stack direction="row" alignItems="center" height="100%">
          <img
            src={`${import.meta.env.VITE_IMG_URL}/${row.img}`}
            alt="icon"
            style={{ height: 40 }}
          />
        </Stack>
      ),
      minWidth: 200,
      flex: 1,
    },
    {
      field: "link",
      headerName: "Link",
      minWidth: 200,
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

  const handleEditModal = (data: TSlider) => {
    //   if (!edit) {
    //     toast.error("You don't have permission");
    //   } else {
    // }
    setModalState({ type: "edit", data });
  };
  const handleDelete = async (id: number) => {
    //   if (!del) {
    //     toast.error("You don't have permission");
    //   } else {
    // }
    handleAsyncToast({
      promise: deleteSlider(id).unwrap(),
      success: () => {
        return "Item deleted successfully!";
      },
    });
  };
  const closeModal = () => setModalState({ type: null });

  return (
    <>
      <HeaderTitle title="Slider" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Slider" />
        <Button onClick={() => setModalState({ type: "add" })}>
          Add Slider
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

      <AddSliderModal open={modalState.type === "add"} setOpen={closeModal} />
      {modalState.type === "edit" && (
        <UpdateSliderModal
          open={modalState.type === "edit"}
          setOpen={closeModal}
          data={modalState.data as TSlider}
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

export default Slider;

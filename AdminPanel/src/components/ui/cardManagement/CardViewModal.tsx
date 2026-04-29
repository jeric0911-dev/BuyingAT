import {
  Box,
  Typography,
  Stack,
  // Avatar,
  Chip,
  Divider,
  Grid,
  Button,
} from "@mui/material";
import { CheckCircle, Cancel } from "@mui/icons-material";
import RCModal from "../../modal/RCModal";
import { TCard } from "../../../types";
import { useApproveCardMutation, useRejectCardMutation } from "../../../redux/features/cardManagement/cardManagementApi";
import handleAsyncToast from "../../../utils/handleAsyncToast";

interface TUpdateModal<T> {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  data: T;
}

const CardViewModal = ({
  open,
  setOpen,
  data,
}: TUpdateModal<TCard>) => {
  const [approveCard] = useApproveCardMutation();
  const [rejectCard] = useRejectCardMutation();

  const handleApprove = async () => {
    handleAsyncToast({
      promise: approveCard(data.id).unwrap(),
      success: () => {
        setOpen(false);
        return "Card approved successfully!";
      },
    });
  };

  const handleReject = async () => {
    handleAsyncToast({
      promise: rejectCard(data.id).unwrap(),
      success: () => {
        setOpen(false);
        return "Card rejected successfully!";
      },
    });
  };

  const cardData = data?.seller_inventory || data;
  const images = cardData?.images || [];

  return (
    <RCModal open={open} setOpen={setOpen} title="Card Details">
      <Box>
        {/* Card Images */}
        {images.length > 0 && (
          <Box mb={3}>
            <Typography variant="h6" gutterBottom>
              Card Images
            </Typography>
            <Grid container spacing={2}>
              {images.map((image, index) => (
                <Grid item xs={12} sm={6} md={4} key={index}>
                  <Box
                    component="img"
                    src={`${import.meta.env.VITE_IMG_URL}/${image}`}
                    alt={`Card image ${index + 1}`}
                    sx={{
                      width: '100%',
                      height: 200,
                      objectFit: 'cover',
                      borderRadius: 1,
                      border: '1px solid #e0e0e0'
                    }}
                  />
                </Grid>
              ))}
            </Grid>
          </Box>
        )}

        <Stack
          direction="row"
          alignItems="center"
          justifyContent="space-between"
          mb={2}
        >
          <Typography variant="h5" fontWeight="bold">
            {cardData?.card_title || 'No Title'}
          </Typography>
          <Chip
            label={data?.request_status}
            color={
              data?.request_status === "approved"
                ? "success"
                : data?.request_status === "pending"
                ? "warning"
                : data?.request_status === "rejected"
                ? "error"
                : "default"
            }
            variant="outlined"
          />
        </Stack>

        <Divider sx={{ my: 2 }} />

        <Grid container spacing={3}>
          <Grid item xs={12} md={6}>
            <Typography variant="h6" gutterBottom>
              Card Information
            </Typography>
            <Stack spacing={2}>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Description
                </Typography>
                <Typography variant="body1">
                  {cardData?.description || 'No description available'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Price
                </Typography>
                <Typography variant="h6" color="primary">
                  ${cardData?.price || 0}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Grade
                </Typography>
                <Typography variant="body1">
                  {cardData?.grade || 'Not specified'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Sport Type
                </Typography>
                <Typography variant="body1">
                  {cardData?.sport_type || 'Not specified'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Weight
                </Typography>
                <Typography variant="body1">
                  {cardData?.weight ? `${cardData.weight}g` : 'Not specified'}
                </Typography>
              </Box>
            </Stack>
          </Grid>

          <Grid item xs={12} md={6}>
            <Typography variant="h6" gutterBottom>
              Seller Information
            </Typography>
            <Stack spacing={2}>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Seller Name
                </Typography>
                <Typography variant="body1">
                  {data?.seller_inventory?.user?.name || 'Unknown'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Email
                </Typography>
                <Typography variant="body1">
                  {data?.seller_inventory?.user?.email || 'Not available'}
                </Typography>
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary">
                  Request Date
                </Typography>
                <Typography variant="body1">
                  {new Date(data?.created_at).toLocaleDateString()}
                </Typography>
              </Box>
            </Stack>
          </Grid>
        </Grid>

        <Divider sx={{ my: 3 }} />

        {/* Action Buttons */}
        {data?.request_status === 'pending' && (
          <Stack direction="row" spacing={2} justifyContent="center">
            <Button
              variant="contained"
              color="success"
              onClick={handleApprove}
              startIcon={<CheckCircle />}
            >
              Approve Card
            </Button>
            <Button
              variant="contained"
              color="error"
              onClick={handleReject}
              startIcon={<Cancel />}
            >
              Reject Card
            </Button>
          </Stack>
        )}
      </Box>
    </RCModal>
  );
};

export default CardViewModal;

import { useParams } from "react-router-dom";
import {
  useCloseTicketMutation,
  useGetTicketDetailsQuery,
  useReplayTicketMutation,
} from "../redux/features/supportTicket/supportTicketApi";
import HeaderTitle from "../components/seo/HeaderTitle";
import { Box, Button, Grid, Stack, Typography } from "@mui/material";
import PageTitle from "../components/ui/shared/PageTitle";
import { FieldValues, SubmitHandler } from "react-hook-form";
import handleAsyncToast from "../utils/handleAsyncToast";
import objectToFormData from "../utils/objectToFormData";
import RCForm from "../components/form/RCForm";
import RCInput from "../components/form/RCInput";
import MessageCard from "../components/ui/supportTicket/MessageCard";
import MultiFileUploader from "../components/form/MultiFileUploader";

const TicketDetails = () => {
  const { id } = useParams<{ id: string }>();
  const { data, isFetching } = useGetTicketDetailsQuery(id || "");
  const [replay] = useReplayTicketMutation();
  const [closeTicket] = useCloseTicketMutation();

  const onSubmit: SubmitHandler<FieldValues> = async (values) => {
    const submittableData = objectToFormData({
      ...values,
      ticket_id: data?.data[0]?.ticket_id,
    });
    handleAsyncToast({
      promise: replay(submittableData).unwrap(),
      success: () => "Reply sent successfully",
    });
  };

  const handleCloseTicket = () => {
    handleAsyncToast({
      promise: closeTicket(id || "").unwrap(),
      success: () => "Ticket closed successfully",
    });
  };

  return (
    <>
      <HeaderTitle title="Support Ticket" />
      <Stack direction="row" justifyContent="space-between" alignItems="center">
        <PageTitle title="Support Ticket" />
      </Stack>
      <Box
        mt="20px"
        border="1px solid #E0E2E7"
        borderRadius={2}
        bgcolor="white"
        overflow="hidden"
        py={1.5}
      >
        <Stack
          direction="row"
          justifyContent="space-between"
          alignItems="center"
          borderBottom="1px solid #E0E2E7"
          px={2.5}
          pb={1.5}
        >
          <Typography>{data?.data?.[0]?.support_ticket.ticket_id}</Typography>
          <Button
            onClick={handleCloseTicket}
            variant={
              data?.data[0]?.support_ticket.status ? "outlined" : "contained"
            }
            size="small"
            color="error"
            disabled={!data?.data[0]?.support_ticket.status}
            sx={{
              color: `${
                data?.data[0]?.support_ticket.status ? "error.main" : "white"
              }`,
              py: "5px",
              px: 1.5,
              fontSize: "12px",
              fontWeight: 600,
            }}
          >
            {data?.data[0]?.support_ticket.status ? "Close Ticket" : "Closed"}
          </Button>
        </Stack>

        <RCForm onSubmit={onSubmit} defaultValues={{ message: "", file: null }}>
          <Grid container spacing={2} mt={1} px={2.5}>
            <Grid item xs={12} md={6}>
              <RCInput name="message" label="Message" />
            </Grid>
            <Grid item xs={12} md={6}>
              <MultiFileUploader name="file" label="Attachment" />
            </Grid>
            <Grid item xs={12}>
              <Button
                type="submit"
                fullWidth
                disabled={!data?.data[0]?.support_ticket.status}
              >
                Replay
              </Button>
            </Grid>
          </Grid>
        </RCForm>

        <Stack spacing={2} mt={4} px={2.5}>
          {isFetching ? (
            <Typography variant="body2" color="textSecondary">
              Loading messages...
            </Typography>
          ) : (
            data?.data?.map((item) => <MessageCard key={item.id} data={item} />)
          )}
        </Stack>
      </Box>
    </>
  );
};

export default TicketDetails;

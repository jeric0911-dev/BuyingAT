import { Grid } from "@mui/material";
import HeaderTitle from "../components/seo/HeaderTitle";
import PageTitle from "../components/ui/shared/PageTitle";
import Card from "../components/ui/home/Card";
import { useGetDashboardMetaQuery } from "../redux/features/others/othersApi";
import activeProduct from "../assets/icon/active-product.svg";
import pendingProduct from "../assets/icon/pending-product.svg";
import rejectedProduct from "../assets/icon/rejected-product.svg";
import activeUser from "../assets/icon/active-user.svg";
import inactiveUser from "../assets/icon/inactive-user.svg";
import activeTicket from "../assets/icon/active-ticket.svg";
import clientQuery from "../assets/icon/client-query.svg";
import successfulDeposit from "../assets/icon/successful-deposit.svg";
import admins from "../assets/icon/admins.svg";
// import categories from "../assets/icon/categories.svg";
import freePackageUser from "../assets/icon/freePackageUser.svg";
import standardPackageUser from "../assets/icon/standardPackageUser.svg";
import premiumPackageUser from "../assets/icon/premiumPackageUser.svg";

const Home = () => {
  const { data, isFetching } = useGetDashboardMetaQuery(undefined);

  return (
    <>
      <HeaderTitle title="Dashboard" />
      <PageTitle title="Home" />
      <Grid container mt={2} spacing={4}>
        {/* Cards */}
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.active_cards as number}
            icon={activeProduct}
            isFetching={isFetching}
            title="Active Cards"
            to="/card-management?status=approved"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.pending_cards as number}
            icon={pendingProduct}
            isFetching={isFetching}
            title="Pending Cards"
            to="/card-management?status=pending"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.rejected_cards as number}
            icon={rejectedProduct}
            isFetching={isFetching}
            title="Rejected Cards"
            to="/card-management?status=rejected"
          />
        </Grid>

        {/* Users */}
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.active_users as number}
            icon={activeUser}
            isFetching={isFetching}
            title="Active Users"
            to="/user-management?status=1"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.inactive_users as number}
            icon={inactiveUser}
            isFetching={isFetching}
            title="Inactive Users"
            to="/user-management?status=0"
          />
        </Grid>

        {/* User Packages */}
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.free_package_users as number}
            icon={freePackageUser}
            isFetching={isFetching}
            title="Free Package Users"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.standard_package_users as number}
            icon={standardPackageUser}
            isFetching={isFetching}
            title="Standard Package Users"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.premium_package_users as number}
            icon={premiumPackageUser}
            isFetching={isFetching}
            title="Premium Package Users"
          />
        </Grid>

        {/* Support */}
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.active_tickets as number}
            icon={activeTicket}
            isFetching={isFetching}
            title="Active Tickets"
            to="/support-ticket?status=1"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.client_queries as number}
            icon={clientQuery}
            isFetching={isFetching}
            title="Client Queries"
          />
        </Grid>

        {/* Other */}
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.successful_deposits as number}
            icon={successfulDeposit}
            isFetching={isFetching}
            title="Successful Deposits"
            to="/transaction-history?status=success"
          />
        </Grid>
        <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.admins as number}
            icon={admins}
            isFetching={isFetching}
            title="Admins"
          />
        </Grid>
        {/* <Grid item xs={12} sm={6} lg={4} xl={3}>
          <Card
            count={data?.data.categories as number}
            icon={categories}
            isFetching={isFetching}
            title="Categories"
          />
        </Grid> */}
      </Grid>
    </>
  );
};

export default Home;

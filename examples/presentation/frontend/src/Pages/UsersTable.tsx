import {
  UsersTablePagePropsSchema,
  type UsersTablePageProps,
  type UsersTableQueryParams,
} from "../generated/schemas";
import { validateProps } from "../lib/validateProps";
import { useTypedRouter } from "../lib/typedRouter";
import {
  PageHeader,
  DeferredInfoBadge,
  UsersDataTable,
  PaginationControls,
  BackToPresentation,
} from "../components";

function UsersTable({
  users,
  page,
  total_pages,
  demo_info,
}: UsersTablePageProps) {
  const router = useTypedRouter<UsersTablePageProps, UsersTableQueryParams>();

  const handlePrevious = () => {
    router.reload({
      data: { page: page - 1 },
      only: ["users", "page"],
    });
  };
  const handleNext = () => {
    router.reload({
      data: { page: page + 1 },
      only: ["users", "page"],
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-purple-800 to-indigo-900 p-8">
      <div className="max-w-4xl mx-auto">
        <PageHeader />
        <DeferredInfoBadge demo_info={demo_info} />
        <UsersDataTable users={users} />
        <PaginationControls
          page={page}
          total_pages={total_pages}
          onPrevious={handlePrevious}
          onNext={handleNext}
        />
        <BackToPresentation slideNumber={19} />
      </div>
    </div>
  );
}

export default validateProps(UsersTable, UsersTablePagePropsSchema);

import type { UserProfilePageProp$ } from "@shared_types/shared_types/users.d.mts";
import type { PageProps } from "../../types/gleam-projections";
import PageContainer from "../../components/layout/PageContainer";
import SectionHeader from "../../components/layout/SectionHeader";
import GridLayout from "../../components/layout/GridLayout";
import ContentCard from "../../components/cards/ContentCard";
import ProfileSection from "../../components/data/ProfileSection";
import TagList from "../../components/data/TagList";

export default function UserProfile(props: PageProps<UserProfilePageProp$>) {
  const userProfile = props.user_profile;
  return (
    <PageContainer>
      <ContentCard variant="elevated" padding="none" className="overflow-hidden">
        <div className="bg-gradient-to-r from-blue-500 to-purple-600 px-6 py-8">
          <h1 className="text-3xl font-bold text-white">{userProfile.name}</h1>
          <p className="text-blue-100 mt-2">{userProfile.email}</p>
        </div>

        <div className="px-6 py-8">
          <GridLayout columns={{ md: 2 }}>
            <ProfileSection
              title="Profile Information"
              fields={[
                { label: "User ID", value: userProfile.id.toString() },
                { label: "Email", value: userProfile.email },
                { label: "Bio", value: userProfile.bio }
              ]}
            />

            <div>
              <SectionHeader title="Interests" />
              <TagList
                tags={userProfile.interests}
                variant="blue"
                emptyMessage="No interests specified."
              />
            </div>
          </GridLayout>
        </div>
      </ContentCard>
    </PageContainer>
  );
}
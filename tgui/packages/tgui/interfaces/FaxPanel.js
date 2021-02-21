import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const FaxPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    is_funmin,
    fax_list,
    dat
  }

  return (
    <Window
      title = "Fax Panel">
      <Window.Content>
        <Section title="Admin Faxes">
          <table>
            <thead>
            <tr>
              <th width='250px'>Name</th>
              <th width='250px'>From Department</th>
              <th width='250px'>To Department</th>
              <th width='250px'>Sent At</th>
              <th width='250px'>Sent By</th>
              <th width='250px'>View</th>
              <th width='250px'>Reply</th>
              <th width='250px'>Replied to</th>
            </tr>
            </thead>
          </table>
        </Section>

        <Section title="Departmental Faxes" >
          <table>
            <thead>
            <tr>
              <th width='250px'>Name</th>
              <th width='250px'>From Department</th>
              <th width='250px'>To Department</th>
              <th width='250px'>Sent At</th>
              <th width='250px'>Sent By</th>
              <th width='250px'>View</th>
            </tr>
            </thead>
          </table>
        </Section>
      </Window.Content>
      </Window>
  )
}

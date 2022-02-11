
import pandas as pd
import dash
import dash_html_components as html
import dash_core_components as dcc
from dash.dependencies import Input, Output
import plotly.express as px

# Read data into dataframe
spacex_df = pd.read_csv("spacex_launch_dash.csv")
max_payload = spacex_df['Payload Mass (kg)'].max()
min_payload = spacex_df['Payload Mass (kg)'].min()

app = dash.Dash(__name__)

app.layout = html.Div(children=[html.H1('SpaceX Launch Records Dashboard',
                                        style={'textAlign': 'center', 'color': '#503D36',
                                               'font-size': 40}),
                                # dropdown list to enable Launch Site selection
                                dcc.Dropdown(id='site-dropdown',
                                            options = [{'label': "All Sites", 'value': 'ALL'},
                                                        {'label': 'CCAFS LC-40', 'value': 'CCAFS LC-40'},
                                                        {'label': 'KSC LC-39A', 'value': 'KSC LC-39A'},
                                                        {'label': 'VAFB SLC-4E', 'value': 'VAFB SLC-4E'},
                                                        {'label': 'CCAFS SLC-40', 'value': 'CCAFS SLC-40'}],
                                            value = 'ALL',
                                            placeholder = "Select a Launch Site",
                                            searchable = True),
                                html.Br(),

                                # pie chart to show the total successful launches count for all sites
                                # If a specific launch site was selected, show the Success vs. Failed counts for the site
                                html.Div(dcc.Graph(id='success-pie-chart', figure = 'figure')),
                                html.Br(),

                                html.P("Payload range (Kg):"),
                                # slider to select payload range
                                dcc.RangeSlider(id='payload-slider',
                                    min=0, max=10000, step=1000,
                                     marks = {0: '0 kg',
                                            1000: '1000 kg',
                                            2000: '2000 kg',
                                            3000: '3000 kg',
                                            4000: '4000 kg',
                                            5000: '5000 kg',
                                            6000: '6000 kg',
                                            7000: '7000 kg',
                                            8000: '8000 kg',
                                            9000: '9000 kg',
                                            10000: '10000 kg'},
                                    value=[min_payload, max_payload]),

                                # scatter chart to show the correlation between payload and launch success
                                html.Div(dcc.Graph(id='success-payload-scatter-chart')),
                                ])

# callback function for `site-dropdown` as input, `success-pie-chart` as output
# Function decorator to specify function input and output
@app.callback(Output(component_id='success-pie-chart', component_property='figure'),
              Input(component_id='site-dropdown', component_property='value'))

def get_pie_chart(entered_site):
    
    if entered_site == 'ALL':
        fig = px.pie(spacex_df, values='class', 
        names='Launch Site', 
        title='Total Success Launches By Site ')

    else :
        filtered_df = spacex_df[spacex_df['Launch Site'] == entered_site]
        filtered_df = filtered_df['class'].value_counts().to_frame().reset_index()
        fig = px.pie(filtered_df , values = 'class',names='index', 
        title='Total Success Launches for site '+ str(entered_site))
    
    return fig

# callback function for `site-dropdown` and `payload-slider` as inputs, `success-payload-scatter-chart` as output
@app.callback(Output(component_id='success-payload-scatter-chart', component_property='figure'),
                [Input(component_id='site-dropdown', component_property='value'), 
                Input(component_id="payload-slider", component_property="value")])

def get_scatter(entered_site, slider_range):

    low, high = slider_range
    slide=(spacex_df['Payload Mass (kg)'] > low) & (spacex_df['Payload Mass (kg)'] < high)
    dropdown_scatter=spacex_df[slide]

    if entered_site == 'ALL':
        fig = px.scatter(
            dropdown_scatter, x='Payload Mass (kg)', y='class',
            hover_data=['Booster Version'],
            color='Booster Version Category',
            title='Correlation between Payload and Success for all Sites')
        
     
    else:
        dropdown_scatter = dropdown_scatter[spacex_df['Launch Site'] == entered_site]
        title_scatter = f'Success by Payload Size for {entered_site}'
        fig=px.scatter(
            dropdown_scatter,x='Payload Mass (kg)', y='class', 
            title = title_scatter, 
            color='Booster Version Category')
    
    return fig

# Run app
if __name__ == '__main__':
    app.run_server()
